//
//  ProfileView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

struct MyProfileView: View {
    let group: GroupModel
    @Binding var refreshTrigger: Bool

    @State private var user: UserModel?
    @State private var metricTotals: [(metricName: String, total: Int)] = []
    @State private var totalPosts: Int = 0
    @State private var isLoading = false
    @State private var showEditProfile = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
                Section {
                    HStack(spacing: 16) {
                        ProfilePictureView(
                            username: user?.username ?? "?",
                            avatarUrl: user?.avatarUrl,
                            size: 64
                        )
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user?.username ?? "Loading...")
                                .font(.title3)
                                .fontWeight(.semibold)
                            if group.createdBy == user?.id {
                                Text("Admin")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                if !metricTotals.isEmpty {
                    Section("Stats in \(group.name)") {
                        HStack {
                            Label("Posts", systemImage: "square.and.pencil")
                            Spacer()
                            Text("\(totalPosts)")
                                .fontWeight(.medium)
                        }
                        ForEach(metricTotals, id: \.metricName) { item in
                            HStack {
                                Label("\(item.metricName) points", systemImage: "star.fill")
                                Spacer()
                                Text(item.total > 0 ? "+\(item.total)" : "\(item.total)")
                                    .fontWeight(.medium)
                                    .foregroundStyle(item.total >= 0 ? .green : .red)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        showEditProfile = true
                    } label: {
                        Label("Edit profile", systemImage: "person.crop.circle")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task { await signOut() }
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
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
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await fetchProfile()
            }
            .onChange(of: group.id) {
                Task { await fetchProfile() }
            }
            .onChange(of: refreshTrigger) {
                Task { await fetchProfile() }
            }
            .refreshable {
                await fetchProfile()
            }
            .sheet(isPresented: $showEditProfile) {
                if let user {
                    EditProfileView(user: user, onSave: {
                        refreshTrigger.toggle()
                    })
                    .presentationDetents([.medium])
                    .presentationBackground(Color(.systemGroupedBackground))
                }
            }
        }
    }

    private func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            user = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            let metrics: [MetricModel] = try await supabase
                .from("metrics")
                .select()
                .eq("group_id", value: group.id)
                .execute()
                .value

            struct PointRow: Decodable {
                let value: Int
                let metricId: UUID
            }

            let pointRows: [PointRow] = try await supabase
                .from("point_assignments")
                .select("value, metric_id")
                .eq("recipient_id", value: userId.uuidString)
                .execute()
                .value

            metricTotals = metrics.compactMap { metric in
                let total = pointRows
                    .filter { $0.metricId == metric.id }
                    .reduce(0) { $0 + $1.value }
                return (metricName: metric.name, total: total)
            }

            struct PostCount: Decodable {
                let id: UUID
            }

            let postRows: [PostCount] = try await supabase
                .from("posts")
                .select("id")
                .eq("group_id", value: group.id)
                .eq("author_id", value: userId.uuidString)
                .execute()
                .value

            totalPosts = postRows.count

        } catch {
            errorMessage = "Fetch profile error: \(error.localizedDescription)"
            print("fetchProfile error:", error)
        }
        isLoading = false
    }

    private func signOut() async {
        do {
            try await supabase.auth.signOut()
        } catch {
            errorMessage = "Sign out error: \(error.localizedDescription)"
            print("signOut error:", error)
        }
    }
}

#Preview {
    MyProfileView(group: GroupModel(
        id: UUID(),
        name: "Study Group",
        createdBy: UUID(),
        joinCode: "ABC123",
        createdAt: Date()
    ), refreshTrigger: .constant(false))
}
