//
//  MetricModel.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import Foundation

struct MetricModel: Codable, Identifiable {
    let id: UUID
    let groupId: UUID
    let name: String
    let description: String?
    let createdAt: Date
}
