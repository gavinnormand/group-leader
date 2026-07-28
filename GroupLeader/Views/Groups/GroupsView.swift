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
    @State private var showJoinGroup = false
    @State private var showCreateGroup = false

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
                    .swipeActions(edge: .trailing) {
                        if group.isAdmin {
                            NavigationLink(destination: GroupSettingsView(group: group, isAdmin: true)) {
                                Image(systemName: "gear")
                            }
                            .tint(.gray)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task { await leaveGroup(group) }
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
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
                Button("Join a group") {
                    showJoinGroup = true
                }
                Button("Create a group") {
                    showCreateGroup = true
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
        .sheet(isPresented: $showJoinGroup) {
            JoinGroupView(
                onJoin: {
                    await fetchGroups()
                }
            )
            .presentationDetents([.medium])
            .presentationBackground(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupView(
                onCreate: {
                    await fetchGroups()
                }
            )
            .presentationDetents([.medium])
            .presentationBackground(Color(.systemGroupedBackground))
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
            errorMessage = "Fetch groups error: \(error.localizedDescription)"
            print("fetchGroups error:", error)
        }
        isLoading = false
    }
    
    private func leaveGroup(_ group: GroupModel) async {
        guard let userId = supabase.auth.currentUser?.id else { return }
        
        if group.isAdmin {
            errorMessage = "You can't leave a group you created. Delete the group instead from group settings."
            return
        }
        
        do {
            struct MemberUpdate: Encodable {
                let is_active: Bool
                let left_at: String
            }

            try await supabase
                .from("group_members")
                .update(MemberUpdate(
                    is_active: false,
                    left_at: ISO8601DateFormatter().string(from: Date())
                ))
                .eq("group_id", value: group.id.uuidString)
                .eq("user_id", value: userId.uuidString)
                .execute()

            if currentGroup?.id == group.id {
                currentGroup = nil
            }

            await fetchGroups()
        } catch {
            errorMessage = "Leave group error: \(error.localizedDescription)"
            print("leaveGroup error:", error)
        }
    }

}

#Preview {
    NavigationStack {
        GroupsView(currentGroup: .constant(nil))
    }
}
