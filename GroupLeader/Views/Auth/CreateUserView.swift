//
//  CreateUserView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI
import PhotosUI
import Supabase

struct CreateUserView: View {
    let onComplete: () async -> Void
    
    private struct UserInsert: Encodable {
        let id: String
        let username: String
        let avatarUrl: String?
    }

    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    if let avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        DefaultProfilePictureView(username: username.isEmpty ? "?" : username, size: 80)
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

                Text("Add a photo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text("Choose a username")
                    .font(.title2.bold())
                Text("This is how others will see you in groups.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textInputStyle()

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Continue") {
                Task { await createUser() }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .disabled(username.isEmpty || isLoading)

            Spacer()
        }
        .padding()
    }

    private func createUser() async {
        isLoading = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            var avatarUrl: String? = nil

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

            try await supabase
                .from("users")
                .insert(UserInsert(id: userId.uuidString, username: username, avatarUrl: avatarUrl))
                .execute()

            await onComplete()
        } catch {
            errorMessage = error.localizedDescription
            print("CreateUser error:", error)
        }
        isLoading = false
    }
}

#Preview {
    CreateUserView(onComplete: {})
}
