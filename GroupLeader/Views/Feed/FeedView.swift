//
//  FeedView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI

struct FeedView: View {
    private let mockPosts: [(username: String, caption: String?, createdAt: Date, assignments: [PointAssignmentDetailModel])] = [
        (
            username: "gavinnormand",
            caption: "Great practice today!",
            createdAt: Date().addingTimeInterval(-3600 * 2),
            assignments: [
                .init(id: UUID(), value: 10, metricName: "Attendance", recipientUsername: "gavinnormand", recipientAvatarUrl: nil),
                .init(id: UUID(), value: 5, metricName: "Effort", recipientUsername: "johndoe", recipientAvatarUrl: nil),
                .init(id: UUID(), value: -2, metricName: "Late", recipientUsername: "sarahm", recipientAvatarUrl: nil)
            ]
        ),
        (
            username: "johndoe",
            caption: nil,
            createdAt: Date().addingTimeInterval(-86400),
            assignments: [
                .init(id: UUID(), value: 8, metricName: "Goals", recipientUsername: "sarahm", recipientAvatarUrl: nil)
            ]
        ),
        (
            username: "sarahm",
            caption: "Solid effort from everyone",
            createdAt: Date().addingTimeInterval(-86400 * 10),
            assignments: [
                .init(id: UUID(), value: 3, metricName: "Effort", recipientUsername: "johndoe", recipientAvatarUrl: nil),
                .init(id: UUID(), value: -1, metricName: "Late", recipientUsername: "gavinnormand", recipientAvatarUrl: nil)
            ]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(mockPosts.indices, id: \.self) { index in
                    let post = mockPosts[index]
                    PostView(
                        username: post.username,
                        avatarUrl: nil,
                        caption: post.caption,
                        pointAssignments: post.assignments,
                        createdAt: post.createdAt
                    )
                    Divider()
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
