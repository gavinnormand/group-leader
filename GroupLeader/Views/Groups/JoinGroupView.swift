//
//  JoinGroupView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct JoinGroupView: View {
    let onJoin: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("Ask your group admin for the 6-character code.")) {
                    TextField("ABC123", text: $code)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: code) { _, newValue in
                            code = String(newValue.prefix(6)).uppercased()
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
            .navigationTitle("Join a group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Join") {
                            Task { await joinGroup() }
                        }
                        .disabled(code.count != 6)
                    }
                }
            }
        }
    }

    private func joinGroup() async {
        isLoading = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            let group: GroupModel = try await supabase
                .from("groups")
                .select()
                .eq("join_code", value: code)
                .single()
                .execute()
                .value

            try await supabase
                .from("group_members")
                .insert(["group_id": group.id.uuidString, "user_id": userId.uuidString])
                .execute()

            await onJoin()
            dismiss()
        } catch {
            errorMessage = "Join group error: \(error.localizedDescription)"
            print("JoinGroup error:", error)
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        JoinGroupView(onJoin: {})
    }
}
