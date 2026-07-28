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
    var onDelete: (() -> Void)? = nil

    @State private var name: String
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    init(group: GroupModel, isAdmin: Bool, onDelete: (() -> Void)? = nil) {
        self.group = group
        self.isAdmin = isAdmin
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
                    ManageMembersView(group: group)
                }
            }

            Section("Metrics") {
                NavigationLink("Manage metrics") {
                    ManageMetricsView(group: group)
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

            Section {
                Button("Delete group", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle("Group settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await saveName() }
                }
                .disabled(name.isEmpty || name == group.name)
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
        do {
            try await supabase
                .from("groups")
                .update(["name": name])
                .eq("id", value: group.id)
                .execute()
            dismiss()
        } catch {
            print("saveName error:", error)
        }
    }

    private func deleteGroup() async {
        do {
            try await supabase
                .from("groups")
                .delete()
                .eq("id", value: group.id)
                .execute()
            dismiss()
            onDelete?()
        } catch {
            print("deleteGroup error:", error)
        }
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
