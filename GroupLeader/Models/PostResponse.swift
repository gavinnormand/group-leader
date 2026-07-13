//
//  PostResponse.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import Foundation

struct PostResponse: Decodable, Identifiable {
    let id: UUID
    let caption: String?
    let createdAt: Date
    let author: AuthorResponse
    let pointAssignments: [PointAssignmentResponse]

    struct AuthorResponse: Decodable {
        let id: UUID
        let username: String
        let avatarUrl: String?
    }

    struct PointAssignmentResponse: Decodable {
        let id: UUID
        let value: Int
        let metric: MetricResponse
        let recipient: RecipientResponse

        struct MetricResponse: Decodable {
            let id: UUID
            let name: String
        }

        struct RecipientResponse: Decodable {
            let id: UUID
            let username: String
            let avatarUrl: String?
        }
    }

    func toDetailModel() -> PostDetailModel {
        PostDetailModel(
            id: id,
            caption: caption,
            createdAt: createdAt,
            authorUsername: author.username,
            authorAvatarUrl: author.avatarUrl,
            pointAssignments: pointAssignments.map {
                PointAssignmentDetailModel(
                    id: $0.id,
                    value: $0.value,
                    metricName: $0.metric.name,
                    recipientUsername: $0.recipient.username,
                    recipientAvatarUrl: $0.recipient.avatarUrl
                )
            }
        )
    }
}
