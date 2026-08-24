//
//  RootView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

enum AppState {
    case unauthenticated
    case needsUsername
    case needsGroup
    case authenticated
}

struct RootView: View {
    @State private var appState: AppState = .unauthenticated
    @State private var currentGroup: GroupModel?

    var body: some View {
        Group {
            switch appState {
            case .unauthenticated:
                AuthView()
            case .needsUsername:
                CreateUserView(onComplete: {
                    await checkGroup()
                })
            case .needsGroup:
                NavigationStack {
                    GroupsView(
                        currentGroup: $currentGroup,
                        onGroupSelected: { _ in
                            appState = .authenticated
                        }
                    )
                }
            case .authenticated:
                if let group = currentGroup {
                    ContentView(group: group, selectedGroup: $currentGroup)
                } else {
                    ProgressView()
                }
            }
        }
        .onChange(of: currentGroup?.id) { _, newId in
            if newId == nil, case .authenticated = appState {
                Task { await checkGroup() }
            }
        }
        .task {
            for await state in supabase.auth.authStateChanges {
                if state.session != nil {
                    await checkUser()
                } else {
                    appState = .unauthenticated
                }
            }
        }
    }

    private func checkUser() async {
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            let _: UserModel = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            await checkGroup()
        } catch let error as URLError {
            print("checkUser network error:", error)
        } catch {
            appState = .needsUsername
        }
    }

    private func checkGroup() async {
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            let memberships: [GroupMemberModel] = try await supabase
                .from("group_members")
                .select()
                .eq("user_id", value: userId)
                .eq("is_active", value: true)
                .execute()
                .value

            if memberships.isEmpty {
                appState = .needsGroup
                currentGroup = nil
                return
            }

            let groupIds = memberships.map { $0.groupId.uuidString }
            let groups: [GroupModel] = try await supabase
                .from("groups")
                .select()
                .in("id", values: groupIds)
                .execute()
                .value

            if let firstGroup = groups.first {
                currentGroup = firstGroup
                appState = .authenticated
            } else {
                appState = .needsGroup
                currentGroup = nil
            }
        } catch {
            print("checkGroup error:", error)
            appState = .needsGroup
            currentGroup = nil
        }
    }
}

#Preview {
    RootView()
}
