//
//  FeedView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

struct FeedView: View {
    let group: GroupModel
    @Binding var refreshTrigger: Bool

    @State private var posts: [PostDetailModel] = []
    @State private var isLoading = false
    @State private var hasMore = true
    @State private var page = 0
    let pageSize = 20

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(posts) { post in
                    PostView(
                        username: post.authorUsername,
                        avatarUrl: post.authorAvatarUrl,
                        caption: post.caption,
                        pointAssignments: post.pointAssignments,
                        createdAt: post.createdAt
                    )
                    Divider()
                }

                if isLoading {
                    ProgressView()
                        .padding(.vertical, 32)
                } else if hasMore {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task { await loadMore() }
                        }
                } else {
                    Text("That's everything")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 32)
                }
            }
        }
        .task {
            await loadMore()
        }
        .onChange(of: group.id) {
            Task {
                posts = []
                page = 0
                hasMore = true
                await loadMore()
            }
        }
        .onChange(of: refreshTrigger) {
            Task {
                posts = []
                page = 0
                hasMore = true
                await loadMore()
            }
        }
        .refreshable {
            refreshTrigger.toggle()
        }
    }

    private func loadMore() async {
        guard !isLoading && hasMore else { return }
        isLoading = true

        do {
            let from = page * pageSize
            let to = from + pageSize - 1

            let response: [PostResponse] = try await supabase
                .from("posts")
                .select("""
                    id,
                    caption,
                    created_at,
                    author:users!posts_author_id_fkey(id, username, avatar_url),
                    point_assignments(
                        id,
                        value,
                        metric:metrics(id, name),
                        recipient:users!point_assignments_recipient_id_fkey(id, username, avatar_url)
                    )
                """)
                .eq("group_id", value: group.id)
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value

            let newPosts = response.map { $0.toDetailModel() }
            posts.append(contentsOf: newPosts)
            page += 1

            if newPosts.count < pageSize {
                hasMore = false
            }
        } catch {
            print("FeedView loadMore error:", error)
            hasMore = false
        }

        isLoading = false
    }
}

#Preview {
    FeedView(group: GroupModel(
        id: UUID(),
        name: "Study Group",
        createdBy: UUID(),
        joinCode: "ABC123",
        createdAt: Date()
    ), refreshTrigger: .constant(false))
}
