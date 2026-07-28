//
//  ProfileView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    let user: UserModel
    let group: GroupModel

    @State private var metricTotals: [(metricName: String, total: Int)] = []
    @State private var totalPosts: Int = 0
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
            Section {
                HStack(spacing: 16) {
                    ProfilePictureView(
                        username: user.username ?? "?",
                        avatarUrl: user.avatarUrl,
                        size: 64
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username ?? "Unknown")
                            .font(.title3)
                            .fontWeight(.semibold)
                        if group.createdBy == user.id {
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
                            Text(item.metricName)
                            Spacer()
                            Text(item.total > 0 ? "+\(item.total)" : "\(item.total)")
                                .fontWeight(.medium)
                                .foregroundStyle(item.total >= 0 ? .green : .red)
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
        .navigationTitle(user.username ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchStats()
        }
    }

    private func fetchStats() async {
        isLoading = true
        errorMessage = nil
        do {
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
                .eq("recipient_id", value: user.id.uuidString)
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
                .eq("author_id", value: user.id.uuidString)
                .execute()
                .value

            totalPosts = postRows.count

        } catch {
            errorMessage = "Fetch stats error: \(error.localizedDescription)"
            print("fetchStats error:", error)
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            user: UserModel(
                id: UUID(),
                username: "johndoe",
                avatarUrl: nil,
                createdAt: Date()
            ),
            group: GroupModel(
                id: UUID(),
                name: "Study Group",
                createdBy: UUID(),
                joinCode: "ABC123",
                createdAt: Date()
            )
        )
    }
}
