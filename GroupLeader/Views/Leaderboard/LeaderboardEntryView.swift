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
        HStack{
            LeaderboardPositionView(position: entry.position)
            Spacer()
            Text(entry.name)
                .bold()
            Spacer()
            Text("\(entry.position) points")
        }
    }
}

#Preview {
    LeaderboardEntryView(
        entry:
            LeaderboardEntry(
                id: UUID(),
                name: "Gavin",
                score: 1250,
                position: 1
            )
    )
}
