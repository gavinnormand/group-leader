//
//  ProfilePictureView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import SwiftUI

struct ProfilePictureView: View {
    let username: String
    let avatarUrl: String?
    var size: CGFloat = 44
    
    var body: some View {
        AsyncImage(url: avatarUrl.flatMap { URL(string: $0) }) { phase in
            if case .success(let image) = phase {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                DefaultProfilePictureView(username: username)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

#Preview {
    ProfilePictureView(username: "gavinnormand", avatarUrl: nil)
    
    ProfilePictureView(username: "gavinnormand", avatarUrl: "https://media.licdn.com/dms/image/v2/D4E03AQEM6555LufEqw/profile-displayphoto-shrink_200_200/B4EZXKGkEKH0Ac-/0/1742852473425?e=2147483647&v=beta&t=klHqvd6aTLouKihpwAIxeFL_n1XuVUZm82HyPIJMpVc")
}
