//
//  ManageMetricsView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct ManageMetricsView: View {
    let group: GroupModel

    @State private var metrics: [MetricModel] = []
    @State private var isLoading = false
    @State private var showAddMetric = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .listRowSeparator(.hidden)
            } else if metrics.isEmpty {
                Text("No metrics yet. Add one to get started.")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(metrics) { metric in
                    Text(metric.name)
                }
                .onDelete { indexSet in
                    Task { await deleteMetrics(at: indexSet) }
                }
            }
        }
        .navigationTitle("Metrics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddMetric = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddMetric) {
            AddMetricView(group: group, onAdd: {
                await fetchMetrics()
            })
            .presentationDetents([.medium])
            .presentationBackground(Color(.systemGroupedBackground))
        }
        .task {
            await fetchMetrics()
        }
        .refreshable {
            await fetchMetrics()
        }
    }

    private func fetchMetrics() async {
        isLoading = true
        do {
            metrics = try await supabase
                .from("metrics")
                .select()
                .eq("group_id", value: group.id)
                .execute()
                .value
        } catch {
            errorMessage = "Fetch metrics error: \(error.localizedDescription)"
            print("fetchMetrics error:", error)
        }
        isLoading = false
    }

    private func deleteMetrics(at indexSet: IndexSet) async {
        let toDelete = indexSet.map { metrics[$0] }
        do {
            for metric in toDelete {
                try await supabase
                    .from("metrics")
                    .delete()
                    .eq("id", value: metric.id)
                    .execute()
            }
            await fetchMetrics()
        } catch {
            errorMessage = "Delete metric error: \(error.localizedDescription)"
            print("deleteMetric error:", error)
        }
    }
}

#Preview {
    NavigationStack {
        ManageMetricsView(group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ))
    }
}
