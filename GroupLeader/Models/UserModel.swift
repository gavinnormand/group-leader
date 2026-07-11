//
//  UserModel.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import Foundation

struct UserModel: Codable, Identifiable {
    let id: UUID
    let username: String
    let avatarUrl: String?
    let createdAt: Date
}
