//
//  EditProfileView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import PhotosUI
import Supabase

struct EditProfileView: View {
    let user: UserModel
    let onSave: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var username: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(user: UserModel, onSave: @escaping () async -> Void) {
        self.user = user
        self.onSave = onSave
        self._username = State(initialValue: user.username ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    if let avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        ProfilePictureView(
                            username: username.isEmpty ? "?" : username,
                            avatarUrl: user.avatarUrl,
                            size: 80
                        )
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.secondary)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                        }
                    }
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            avatarImage = image
                        }
                    }
                }

                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { await saveProfile() }
                        }
                        .fontWeight(.semibold)
                        .disabled(username.isEmpty)
                    }
                }
            }
        }
    }

    private func saveProfile() async {
        isLoading = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            var avatarUrl = user.avatarUrl

            if let avatarImage,
               let imageData = avatarImage.jpegData(compressionQuality: 0.8) {
                let path = "\(userId.uuidString)/avatar.jpg"
                try await supabase.storage
                    .from("avatars")
                    .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))
                let url = try supabase.storage
                    .from("avatars")
                    .getPublicURL(path: path)
                avatarUrl = url.absoluteString
            }

            struct UserUpdate: Encodable {
                let username: String
                let avatar_url: String?
            }

            try await supabase
                .from("users")
                .update(UserUpdate(username: username, avatar_url: avatarUrl))
                .eq("id", value: userId.uuidString)
                .execute()

            await onSave()
            dismiss()
        } catch {
            errorMessage = "That username is taken. Try another."
            print("saveProfile error:", error)
        }
        isLoading = false
    }
}

#Preview {
    EditProfileView(
        user: UserModel(
            id: UUID(),
            username: "gavinnormand",
            avatarUrl: nil,
            createdAt: Date()
        ),
        onSave: {}
    )
}
