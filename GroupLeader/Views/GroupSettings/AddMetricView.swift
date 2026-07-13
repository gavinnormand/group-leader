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
            VStack(spacing: 24) {
                Spacer()

                Text("New metric")
                    .font(.title2.bold())

                TextField("Metric name (e.g. Attendance)", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button("Add") {
                    Task { await addMetric() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Add metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
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
                .insert(MetricInsert(group_id: group.id, name: name))
                .execute()

            await onAdd()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
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
