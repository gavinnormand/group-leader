//
//  ContentView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Image(systemName: "newspaper")
                }
                .tag(0)

            Text("Leaderboard")
                .tabItem {
                    Image(systemName: "trophy")
                }
                .tag(1)

            NewPostView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
                .tag(2)

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
