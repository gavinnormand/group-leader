//
//  PostDetailModel.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import Foundation

struct PostDetailModel: Identifiable {
    let id: UUID
    let caption: String?
    let createdAt: Date
    let authorUsername: String
    let authorAvatarUrl: String?
    let pointAssignments: [PointAssignmentDetailModel]
}
