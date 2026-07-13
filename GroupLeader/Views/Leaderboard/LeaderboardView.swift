//
//  LeaderboardView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI
import Supabase

struct LeaderboardView: View {
    let group: GroupModel

    @State private var metrics: [MetricModel] = []
    @State private var selectedMetric: MetricModel?
    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoadingMetrics = false
    @State private var isLoadingEntries = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // metric picker
            if !metrics.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(metrics) { metric in
                            Button {
                                selectedMetric = metric
                            } label: {
                                Text(metric.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(selectedMetric?.id == metric.id ? Color.accentColor : Color(.systemGray6))
                                    .foregroundStyle(selectedMetric?.id == metric.id ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                Divider()
            }

            if isLoadingEntries {
                Spacer()
                ProgressView()
                Spacer()
            } else if entries.isEmpty {
                Spacer()
                Text(metrics.isEmpty ? "No metrics yet." : "No points recorded yet.")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(entries) { entry in
                            NavigationLink(destination: ProfileView(
                                user: UserModel(
                                    id: entry.id,
                                    username: entry.username,
                                    avatarUrl: entry.avatarUrl,
                                    createdAt: Date()
                                ),
                                group: group
                            )) {
                                LeaderboardEntryView(entry: entry)
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchMetrics()
        }
        .onChange(of: selectedMetric?.id) {
            Task { await fetchEntries() }
        }
        .onChange(of: group.id) {
            Task {
                entries = []
                selectedMetric = nil
                await fetchMetrics()
            }
        }
    }

    private func fetchMetrics() async {
        isLoadingMetrics = true
        errorMessage = nil
        do {
            metrics = try await supabase
                .from("metrics")
                .select()
                .eq("group_id", value: group.id)
                .execute()
                .value
            selectedMetric = metrics.first
        } catch {
            errorMessage = error.localizedDescription
            print("fetchMetrics error:", error)
        }
        isLoadingMetrics = false
    }

    private func fetchEntries() async {
        guard let metric = selectedMetric else { return }
        isLoadingEntries = true
        errorMessage = nil
        do {
            struct PointRow: Decodable {
                let recipientId: UUID
                let value: Int
            }

            let pointRows: [PointRow] = try await supabase
                .from("point_assignments")
                .select("recipient_id, value")
                .eq("metric_id", value: metric.id)
                .execute()
                .value

            // group by recipient and sum
            var totals: [UUID: Int] = [:]
            for row in pointRows {
                totals[row.recipientId, default: 0] += row.value
            }

            if totals.isEmpty {
                entries = []
                isLoadingEntries = false
                return
            }

            // fetch user info for each recipient
            let userIds = totals.keys.map { $0.uuidString }
            let users: [UserModel] = try await supabase
                .from("users")
                .select()
                .in("id", values: userIds)
                .execute()
                .value

            // build sorted entries
            entries = users
                .compactMap { user -> LeaderboardEntry? in
                    guard let total = totals[user.id] else { return nil }
                    return LeaderboardEntry(
                        id: user.id,
                        username: user.username ?? "Unknown",
                        avatarUrl: user.avatarUrl,
                        totalPoints: total,
                        position: 0
                    )
                }
                .sorted { $0.totalPoints > $1.totalPoints }
                .enumerated()
                .map { index, entry in
                    LeaderboardEntry(
                        id: entry.id,
                        username: entry.username,
                        avatarUrl: entry.avatarUrl,
                        totalPoints: entry.totalPoints,
                        position: index + 1
                    )
                }

        } catch {
            errorMessage = error.localizedDescription
            print("fetchEntries error:", error)
        }
        isLoadingEntries = false
    }
}

#Preview {
    NavigationStack {
        LeaderboardView(group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ))
    }
}
