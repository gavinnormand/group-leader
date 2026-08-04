//
//  LeaderboardView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI
import Supabase

enum TimeFilter: String, CaseIterable {
    case allTime = "All time"
    case thirtyDays = "30 days"
    case sevenDays = "7 days"
    case oneDay = "1 day"

    var startDate: Date? {
        switch self {
        case .allTime: return nil
        case .thirtyDays: return Calendar.current.date(byAdding: .day, value: -30, to: Date())
        case .sevenDays: return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .oneDay: return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        }
    }
}

struct LeaderboardView: View {
    let group: GroupModel

    @State private var metrics: [MetricModel] = []
    @State private var selectedMetric: MetricModel?
    @State private var selectedFilter: TimeFilter = .allTime
    @State private var entries: [LeaderboardEntry] = []
    @State private var usersById: [UUID: UserModel] = [:]
    @State private var isLoadingMetrics = false
    @State private var isLoadingEntries = false
    @State private var errorMessage: String?
    @State private var fetchId = UUID()

    var body: some View {
        VStack(spacing: 0) {
            if !metrics.isEmpty {
                // metric picker
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

                HStack(spacing: 8) {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedFilter == filter ? Color.accentColor : Color(.systemGray6))
                                .foregroundStyle(selectedFilter == filter ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()
            }

            if isLoadingEntries {
                Spacer()
                ProgressView()
                Spacer()
            } else if entries.isEmpty {
                Spacer()
                Text(metrics.isEmpty ? "No metrics yet." : "No points recorded.")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(entries) { entry in
                            if let user = usersById[entry.id] {
                            NavigationLink(destination: ProfileView(
                                user: user,
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
        .onChange(of: selectedFilter) {
            Task { await fetchEntries() }
        }
        .onChange(of: group.id) {
            Task {
                entries = []
                selectedMetric = nil
                selectedFilter = .allTime
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
            errorMessage = "Fetch metrics error: \(error.localizedDescription)"
            print("fetchMetrics error:", error)
        }
        isLoadingMetrics = false
    }

    private func fetchEntries() async {
        guard let metric = selectedMetric else { return }
        let currentFetchId = UUID()
        fetchId = currentFetchId
        isLoadingEntries = true
        errorMessage = nil
        do {
            struct PointRow: Decodable {
                let recipientId: UUID
                let value: Int
            }

            var query = supabase
                .from("point_assignments")
                .select("recipient_id, value")
                .eq("metric_id", value: metric.id)

            if let startDate = selectedFilter.startDate {
                let formatter = ISO8601DateFormatter()
                query = query.gte("created_at", value: formatter.string(from: startDate))
            }

            let pointRows: [PointRow] = try await query
                .execute()
                .value

            var totals: [UUID: Int] = [:]
            for row in pointRows {
                totals[row.recipientId, default: 0] += row.value
            }

            guard fetchId == currentFetchId else { return }

            if totals.isEmpty {
                entries = []
                isLoadingEntries = false
                return
            }

            let userIds = totals.keys.map { $0.uuidString }
            let users: [UserModel] = try await supabase
                .from("users")
                .select()
                .in("id", values: userIds)
                .execute()
                .value

            guard fetchId == currentFetchId else { return }

            usersById = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })

            entries = users
                .compactMap { user -> LeaderboardEntry? in
                    guard let total = totals[user.id] else { return nil }
                    return LeaderboardEntry(
                        id: user.id,
                        username: user.username,
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
            errorMessage = "Fetch entries error: \(error.localizedDescription)"
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
