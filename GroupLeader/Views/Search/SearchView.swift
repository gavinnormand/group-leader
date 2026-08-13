//
//  SearchView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

struct SearchView: View {
    let group: GroupModel

    @State private var query = ""
    @State private var members: [UserModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var filtered: [UserModel] {
        if query.isEmpty { return members }
        return members.filter {
            ($0.username).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search members", text: $query)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()

            List {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                } else if members.isEmpty {
                    Text("No members in this group yet.")
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                } else if filtered.isEmpty {
                    Text("No results for \"\(query)\"")
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filtered) { member in
                        NavigationLink(destination: ProfileView(user: member, group: group)) {
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
            .listStyle(.plain)
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchMembers()
        }
        .onChange(of: group.id) {
            Task { await fetchMembers() }
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
}

#Preview {
    NavigationStack {
        SearchView(group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ))
    }
}
