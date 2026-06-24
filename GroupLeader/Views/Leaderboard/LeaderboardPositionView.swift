//
//  LeaderboardPositionView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI

struct LeaderboardPositionView: View {
    let position: Int
    
    var backgroundColor: Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
    
    var body: some View {
        Group {
            if position <= 3 {
                Text("\(position)")
                    .foregroundColor(.white)
            } else {
                Text("\(position)")
            }
        }
        .frame(width: 40, height: 40)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    LeaderboardPositionView(position: 1)
    LeaderboardPositionView(position: 2)
    LeaderboardPositionView(position: 3)
    LeaderboardPositionView(position: 4)
}
