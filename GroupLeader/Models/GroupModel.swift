//
//  GroupModel.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import Foundation
import Supabase

struct GroupModel: Codable, Identifiable {
    let id: UUID
    let name: String
    let createdBy: UUID
    let joinCode: String
    let createdAt: Date
    
    var isAdmin: Bool {
        supabase.auth.currentUser?.id == createdBy
    }
}
