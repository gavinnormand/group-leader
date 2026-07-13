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
        VStack(spacing: 24) {
            Spacer()

            Text("Enter join code")
                .font(.title2.bold())

            TextField("ABC123", text: $code)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.prefix(6)).uppercased()
                }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Join") {
                Task { await joinGroup() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(code.count != 6 || isLoading)

            Spacer()
        }
        .padding()
        .navigationTitle("Join a group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isLoading { ProgressView() }
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
            errorMessage = "Group not found. Check the code and try again."
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
