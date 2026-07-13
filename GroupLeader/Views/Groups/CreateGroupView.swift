//
//  CreateGroupView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import Supabase

struct CreateGroupView: View {
    let onCreate: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private struct GroupInsert: Encodable {
        let name: String
        let created_by: UUID
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Name your group")
                .font(.title2.bold())

            TextField("Group name", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Create") {
                Task { await createGroup() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || isLoading)

            Spacer()
        }
        .padding()
        .navigationTitle("New group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isLoading { ProgressView() }
            }
        }
    }

    private func createGroup() async {
        isLoading = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            let group: GroupModel = try await supabase
                .from("groups")
                .insert(GroupInsert(name: name, created_by: userId))
                .select()
                .single()
                .execute()
                .value

            try await supabase
                .from("group_members")
                .insert(["group_id": group.id.uuidString, "user_id": userId.uuidString])
                .execute()

            await onCreate()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            print("CreateGroup error:", error)
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        CreateGroupView(onCreate: {})
    }
}
