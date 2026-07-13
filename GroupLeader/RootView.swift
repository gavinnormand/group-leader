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
    case authenticated(group: GroupModel)
}

struct RootView: View {
    @State private var appState: AppState = .unauthenticated

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
                        currentGroup: .constant(nil),
                        onGroupSelected: { group in
                            appState = .authenticated(group: group)
                        }
                    )
                }
            case .authenticated(let group):
                ContentView(currentGroup: group)
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
                appState = .authenticated(group: firstGroup)
            } else {
                appState = .needsGroup
            }
        } catch {
            print("checkGroup error:", error)
            appState = .needsGroup
        }
    }
}

#Preview {
    RootView()
}
