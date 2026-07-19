//
//  PointAssignmentView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import SwiftUI

struct PointAssignmentView: View {
    let assignment: PointAssignmentDetailModel

    var body: some View {
        HStack(spacing: 10) {
            ProfilePictureView(username: assignment.recipientUsername, avatarUrl: assignment.recipientAvatarUrl, size: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(assignment.recipientUsername)
                    .font(.system(size: 13, weight: .medium))
                Text(assignment.metricName + " points")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(assignment.value > 0 ? "+\(assignment.value)" : "\(assignment.value)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(assignment.value > 0 ? Color.green : Color.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(assignment.value > 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    VStack(spacing: 2) {
        PointAssignmentView(assignment: .init(id: UUID(), value: 1, metricName: "Sniper", recipientUsername: "gavinnormand", recipientAvatarUrl: nil))
        PointAssignmentView(assignment: .init(id: UUID(), value: 1, metricName: "Sniped", recipientUsername: "anair", recipientAvatarUrl: nil))
        PointAssignmentView(assignment: .init(id: UUID(), value: -100, metricName: "Aura", recipientUsername: "anair", recipientAvatarUrl: nil))
    }
    .padding()
}
