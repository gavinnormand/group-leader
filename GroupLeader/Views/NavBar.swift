//
//  NavBar.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI

struct NavBar: View {
    var body: some View {
        HStack {
            Image(systemName: "text.justify")
            Image(systemName: "newspaper")
            Image(systemName: "plus.circle")
            Image(systemName: "trophy")
            Image(systemName: "person")
        }
    }
}

#Preview {
    NavBar()
}
