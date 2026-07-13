//
//  LeaderboardEntryView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI

struct LeaderboardEntryView: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: 12) {
            LeaderboardPositionView(position: entry.position)
            ProfilePictureView(username: entry.username, avatarUrl: entry.avatarUrl, size: 36)
            Text(entry.username)
                .fontWeight(.semibold)
            Spacer()
            Text(entry.totalPoints > 0 ? "+\(entry.totalPoints)" : "\(entry.totalPoints)")
                .fontWeight(.medium)
                .foregroundStyle(entry.totalPoints >= 0 ? .green : .red)
        }
    }
}

#Preview {
    LeaderboardEntryView(entry: LeaderboardEntry(
        id: UUID(),
        username: "gavinnormand",
        avatarUrl: nil,
        totalPoints: 1250,
        position: 1
    ))
    .padding()
}
