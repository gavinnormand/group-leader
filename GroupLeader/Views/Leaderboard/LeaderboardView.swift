//
//  LeaderboardView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI

struct LeaderboardView: View {
    let entries: [LeaderboardEntry]
    
    var body: some View {
        VStack {
            ForEach(entries) { entry in
                LeaderboardEntryView(entry: entry)
            }
        }
        .padding()
    }
}

#Preview {
    LeaderboardView(entries: [
        LeaderboardEntry(id: UUID(), name: "Gavin", score: 1250, position: 1),
        LeaderboardEntry(id: UUID(), name: "Alex", score: 1180, position: 2),
        LeaderboardEntry(id: UUID(), name: "Sarah", score: 1125, position: 3),
        LeaderboardEntry(id: UUID(), name: "Jordan", score: 1050, position: 4),
        LeaderboardEntry(id: UUID(), name: "Emma", score: 980, position: 5),
        LeaderboardEntry(id: UUID(), name: "Noah", score: 950, position: 6),
        LeaderboardEntry(id: UUID(), name: "Olivia", score: 920, position: 7),
        LeaderboardEntry(id: UUID(), name: "Liam", score: 875, position: 8),
        LeaderboardEntry(id: UUID(), name: "Ava", score: 840, position: 9),
        LeaderboardEntry(id: UUID(), name: "Ethan", score: 810, position: 10),
        LeaderboardEntry(id: UUID(), name: "Mia", score: 770, position: 11),
        LeaderboardEntry(id: UUID(), name: "Lucas", score: 730, position: 12),
        LeaderboardEntry(id: UUID(), name: "Sophia", score: 690, position: 13),
        LeaderboardEntry(id: UUID(), name: "James", score: 650, position: 14),
        LeaderboardEntry(id: UUID(), name: "Charlotte", score: 620, position: 15)
    ])
}
