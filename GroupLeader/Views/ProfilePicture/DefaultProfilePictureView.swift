//
//  DefaultProfilePictureView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/10/26.
//

import SwiftUI

struct DefaultProfilePictureView: View {
    let username: String
    var size: CGFloat = 44

    private var initials: String {
        String(username.prefix(1)).uppercased()
    }

    private var fontSize: CGFloat {
        size * 0.35
    }

    var body: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.25))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(Color.accentColor)
            )
    }
}

#Preview {
    HStack(spacing: 16) {
        DefaultProfilePictureView(username: "gavinnormand", size: 28)
        DefaultProfilePictureView(username: "gavinnormand", size: 44)
        DefaultProfilePictureView(username: "gavinnormand", size: 60)
        DefaultProfilePictureView(username: "gavinnormand")
    }
}
