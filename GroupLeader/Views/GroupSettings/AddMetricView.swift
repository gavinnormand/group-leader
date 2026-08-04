//
//  AddMetricView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct AddMetricView: View {
    let group: GroupModel
    let onAdd: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("New metric")) {
                    TextField("Metric name (e.g. Attendance)", text: $name)
                        .onChange(of: name) { _, newValue in
                            if newValue.count > 30 { name = String(newValue.prefix(30)) }
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
            .navigationTitle("Add metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Create") {
                            Task { await addMetric() }
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    private func addMetric() async {
        isLoading = true
        errorMessage = nil
        do {
            struct MetricInsert: Encodable {
                let group_id: UUID
                let name: String
            }

            try await supabase
                .from("metrics")
                .insert(MetricInsert(group_id: group.id, name: name.trimmingCharacters(in: .whitespaces)))
                .execute()

            await onAdd()
            dismiss()
        } catch {
            errorMessage = "Add metric error: \(error.localizedDescription)"
            print("addMetric error:", error)
        }
        isLoading = false
    }
}

#Preview {
    AddMetricView(
        group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ),
        onAdd: {}
    )
}
