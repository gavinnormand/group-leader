//
//  GroupMemberModel.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import Foundation

struct GroupMemberModel: Codable, Identifiable {
    let id: UUID
    let groupId: UUID
    let userId: UUID
    let isActive: Bool
    let joinedAt: Date
    let leftAt: Date?
}
