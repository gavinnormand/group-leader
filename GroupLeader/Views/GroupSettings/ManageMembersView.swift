//
//  ManageMembersView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct ManageMembersView: View {
    let group: GroupModel

    @State private var members: [UserModel] = []
    @State private var isLoading = false
    @State private var removingMemberId: UUID?
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if members.isEmpty {
                Text("No members yet.")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(members) { member in
                    HStack(spacing: 12) {
                        ProfilePictureView(
                            username: member.username,
                            avatarUrl: member.avatarUrl,
                            size: 36
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.username)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if member.id == group.createdBy {
                                Text("Admin")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if member.id != group.createdBy {
                            if removingMemberId == member.id {
                                ProgressView()
                            } else {
                                Button(role: .destructive) {
                                    Task { await removeMember(member) }
                                } label: {
                                    Image(systemName: "person.badge.minus")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                                .disabled(removingMemberId != nil)
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
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchMembers()
        }
        .refreshable {
            await fetchMembers()
        }
    }

    private func fetchMembers() async {
        isLoading = true
        errorMessage = nil
        do {
            let memberships: [GroupMemberModel] = try await supabase
                .from("group_members")
                .select()
                .eq("group_id", value: group.id)
                .eq("is_active", value: true)
                .execute()
                .value

            let userIds = memberships.map { $0.userId.uuidString }

            if userIds.isEmpty {
                members = []
                isLoading = false
                return
            }

            members = try await supabase
                .from("users")
                .select()
                .in("id", values: userIds)
                .execute()
                .value

        } catch {
            errorMessage = "Fetch members error: \(error.localizedDescription)"
            print("fetchMembers error:", error)
        }
        isLoading = false
    }

    private func removeMember(_ member: UserModel) async {
        removingMemberId = member.id
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
                .eq("group_id", value: group.id)
                .eq("user_id", value: member.id)
                .execute()
            await fetchMembers()
        } catch {
            errorMessage = "Remove member error: \(error.localizedDescription)"
            print("removeMember error:", error)
        }
        removingMemberId = nil
    }
}

#Preview {
    NavigationStack {
        ManageMembersView(group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ))
    }
}
