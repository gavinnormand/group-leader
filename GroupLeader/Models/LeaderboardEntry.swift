//
//  LeaderboardEntry.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import Foundation

struct LeaderboardEntry: Identifiable {
    let id: UUID
    let username: String
    let avatarUrl: String?
    let totalPoints: Int
    let position: Int
}
