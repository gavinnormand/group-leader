//
//  GroupsView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

struct GroupsView: View {
    @Binding var currentGroup: GroupModel?
    var onGroupSelected: ((GroupModel) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var groups: [GroupModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if groups.isEmpty {
                Text("You're not in any groups yet.")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(groups) { group in
                    Button {
                        currentGroup = group
                        onGroupSelected?(group)
                        dismiss()
                    } label: {
                        HStack {
                            DefaultProfilePictureView(username: group.name, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            if currentGroup?.id == group.id {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section {
                NavigationLink("Join a group") {
                    JoinGroupView(onJoin: {
                        await fetchGroups()
                    })
                }
                NavigationLink("Create a group") {
                    CreateGroupView(onCreate: {
                        await fetchGroups()
                    })
                }
            }
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchGroups()
        }
        .refreshable {
            await fetchGroups()
        }
    }

    private func fetchGroups() async {
        isLoading = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            let memberships: [GroupMemberModel] = try await supabase
                .from("group_members")
                .select()
                .eq("user_id", value: userId)
                .eq("is_active", value: true)
                .execute()
                .value

            let groupIds = memberships.map { $0.groupId.uuidString }

            if groupIds.isEmpty {
                groups = []
                isLoading = false
                return
            }

            groups = try await supabase
                .from("groups")
                .select()
                .in("id", values: groupIds)
                .execute()
                .value

            if currentGroup == nil {
                currentGroup = groups.first
            }
        } catch {
            errorMessage = error.localizedDescription
            print("fetchGroups error:", error)
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        GroupsView(currentGroup: .constant(nil))
    }
}
