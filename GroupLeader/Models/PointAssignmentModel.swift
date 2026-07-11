//
//  PointAssignmentModel.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import Foundation

struct PointAssignmentModel: Codable, Identifiable {
    let id: UUID
    let postId: UUID
    let metricId: UUID
    let recipientId: UUID
    let value: Int
    let createdAt: Date
}

struct PointAssignmentDetailModel: Identifiable {
    let id: UUID
    let value: Int
    let metricName: String
    let recipientUsername: String
    let recipientAvatarUrl: String?
}
