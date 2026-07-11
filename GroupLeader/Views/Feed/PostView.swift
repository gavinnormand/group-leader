//
//  PostView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct PostView: View {
    let username: String
    let avatarUrl: String?
    let caption: String?
    let pointAssignments: [PointAssignmentDetailModel]
    let createdAt: Date

    private var timeAgo: String {
        let seconds = Int(Date().timeIntervalSince(createdAt))
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24

        switch seconds {
        case ..<60:        return "\(seconds)s"
        case ..<3600:      return "\(minutes)m"
        case ..<86400:     return "\(hours)h"
        case ..<604800:    return "\(days)d"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yy"
            return formatter.string(from: createdAt)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                ProfilePictureView(username: username, avatarUrl: avatarUrl)
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(username)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(timeAgo)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    if let caption {
                        Text(caption)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            VStack(spacing: 2) {
                ForEach(pointAssignments) { assignment in
                    PointAssignmentView(assignment: assignment)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PostView(
        username: "gavinnormand",
        avatarUrl: nil,
        caption: "Abhi got SNIPEEDDDDD",
        pointAssignments: [
            .init(id: UUID(), value: 1, metricName: "Sniper", recipientUsername: "gavinnormand", recipientAvatarUrl: nil),
            .init(id: UUID(), value: 1, metricName: "Sniped", recipientUsername: "anair", recipientAvatarUrl: nil),
            .init(id: UUID(), value: -100, metricName: "Aura", recipientUsername: "anair", recipientAvatarUrl: nil)
        ],
        createdAt: Date().addingTimeInterval(-3600 * 8)
    )
    .padding()
}
