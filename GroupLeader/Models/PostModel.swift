//
//  Post.Modelswift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import Foundation

struct PostModel: Codable, Identifiable {
    let id: UUID
    let groupId: UUID
    let authorId: UUID
    let caption: String?
    let createdAt: Date
}
