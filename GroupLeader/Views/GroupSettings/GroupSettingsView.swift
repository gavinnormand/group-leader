//
//  GroupSettingsView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct GroupSettingsView: View {
    let group: GroupModel
    let isAdmin: Bool
    var onUpdate: ((GroupModel) async -> Void)? = nil
    var onDelete: (() async -> Void)? = nil

    @State private var name: String
    @State private var showDeleteConfirm = false
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    init(
        group: GroupModel,
        isAdmin: Bool,
        onUpdate: ((GroupModel) async -> Void)? = nil,
        onDelete: (() async -> Void)? = nil
    ) {
        self.group = group
        self.isAdmin = isAdmin
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self._name = State(initialValue: group.name)
    }

    var body: some View {
        List {
            Section("Group info") {
                TextField("Group name", text: $name)
            }

            Section("Members") {
                NavigationLink("Manage members") {
                    ManageMembersView(group: group, onChange: { await onUpdate?(group) })
                }
            }

            Section("Metrics") {
                NavigationLink("Manage metrics") {
                    ManageMetricsView(group: group, onChange: { await onUpdate?(group) })
                }
            }

            Section(footer: Text("Share this code so others can join the group.")) {
                HStack {
                    Text("Join code")
                    Spacer()
                    Text(group.joinCode)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Button {
                        UIPasteboard.general.string = group.joinCode
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
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
                Button("Delete group", role: .destructive) {
                    showDeleteConfirm = true
                }
                .disabled(isDeleting)
            }
        }
        .navigationTitle("Group settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task { await saveName() }
                    }
                    .disabled(name.isEmpty || name == group.name)
                }
            }
        }
        .confirmationDialog(
            "Delete this group?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete group", role: .destructive) {
                Task { await deleteGroup() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the group and all its posts and point history. This can't be undone.")
        }
    }

    private func saveName() async {
        isSaving = true
        do {
            let updatedGroup: GroupModel = try await supabase
                .from("groups")
                .update(["name": name])
                .eq("id", value: group.id)
                .select()
                .single()
                .execute()
                .value
            await onUpdate?(updatedGroup)
            dismiss()
        } catch {
            errorMessage = "Save name error: \(error.localizedDescription)"
            print("saveName error:", error)
        }
        isSaving = false
    }

    private func deleteGroup() async {
        isDeleting = true
        do {
            try await supabase
                .from("groups")
                .delete()
                .eq("id", value: group.id)
                .execute()
            await onDelete?()
            dismiss()
        } catch {
            errorMessage = "Delete group error: \(error.localizedDescription)"
            print("deleteGroup error:", error)
        }
        isDeleting = false
    }
}

#Preview {
    NavigationStack {
        GroupSettingsView(
            group: GroupModel(
                id: UUID(),
                name: "Study Group",
                createdBy: UUID(),
                joinCode: "ABC123",
                createdAt: Date()
            ),
            isAdmin: true
        )
    }
}
