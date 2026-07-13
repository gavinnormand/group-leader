//
//  NewPostView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

struct NewPostView: View {
    let group: GroupModel
    let onPost: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var assignments: [AssignmentDraft] = []
    @State private var members: [UserModel] = []
    @State private var metrics: [MetricModel] = []
    @State private var isLoading = false
    @State private var isPosting = false
    @State private var errorMessage: String?

    struct AssignmentDraft: Identifiable {
        let id = UUID()
        var recipient: UserModel?
        var metric: MetricModel?
        var value: Int = 1
    }

    var canPost: Bool {
        !assignments.isEmpty &&
        assignments.allSatisfy { $0.recipient != nil && $0.metric != nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // caption
                    TextField("Add a caption (optional)", text: $caption, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    // assignments
                    Text("Point assignments")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ForEach($assignments) { $assignment in
                        AssignmentRowView(
                            assignment: $assignment,
                            members: members,
                            metrics: metrics,
                            onDelete: {
                                assignments.removeAll { $0.id == assignment.id }
                            }
                        )
                    }

                    Button {
                        assignments.append(AssignmentDraft())
                    } label: {
                        Label("Add assignment", systemImage: "plus.circle")
                            .font(.subheadline)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("New post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Button("Post") {
                            Task { await submitPost() }
                        }
                        .fontWeight(.semibold)
                        .disabled(!canPost)
                    }
                }
            }
            .task {
                await fetchMembersAndMetrics()
            }
        }
    }

    private func fetchMembersAndMetrics() async {
        isLoading = true
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            // fetch group members
            let memberships: [GroupMemberModel] = try await supabase
                .from("group_members")
                .select()
                .eq("group_id", value: group.id)
                .eq("is_active", value: true)
                .execute()
                .value

            let userIds = memberships.map { $0.userId.uuidString }

            members = try await supabase
                .from("users")
                .select()
                .in("id", values: userIds)
                .execute()
                .value

            // fetch metrics for this group
            metrics = try await supabase
                .from("metrics")
                .select()
                .eq("group_id", value: group.id)
                .execute()
                .value

        } catch {
            errorMessage = error.localizedDescription
            print("fetchMembersAndMetrics error:", error)
        }
        isLoading = false
    }

    private func submitPost() async {
        isPosting = true
        errorMessage = nil
        guard let userId = supabase.auth.currentUser?.id else { return }
        do {
            // insert post
            struct PostInsert: Encodable {
                let group_id: UUID
                let author_id: UUID
                let caption: String?
            }

            let post: PostModel = try await supabase
                .from("posts")
                .insert(PostInsert(
                    group_id: group.id,
                    author_id: userId,
                    caption: caption.isEmpty ? nil : caption
                ))
                .select()
                .single()
                .execute()
                .value

            // insert point assignments
            struct PointAssignmentInsert: Encodable {
                let post_id: UUID
                let metric_id: UUID
                let recipient_id: UUID
                let value: Int
            }

            let inserts = assignments.compactMap { draft -> PointAssignmentInsert? in
                guard let recipient = draft.recipient,
                      let metric = draft.metric else { return nil }
                return PointAssignmentInsert(
                    post_id: post.id,
                    metric_id: metric.id,
                    recipient_id: recipient.id,
                    value: draft.value
                )
            }

            try await supabase
                .from("point_assignments")
                .insert(inserts)
                .execute()

            await onPost()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            print("submitPost error:", error)
        }
        isPosting = false
    }
}

#Preview {
    NewPostView(
        group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ),
        onPost: {}
    )
}
