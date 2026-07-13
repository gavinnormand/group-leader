//
//  ContentView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var currentGroup: GroupModel
    @State private var isAdmin = false
    @State private var showNewPost = false
    @State private var feedRefreshTrigger = false

    init(currentGroup: GroupModel) {
        self._currentGroup = State(initialValue: currentGroup)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    NavigationLink(destination: GroupsView(
                        currentGroup: Binding(
                            get: { currentGroup },
                            set: { if let g = $0 { currentGroup = g } }
                        )
                    )) {
                        HStack(spacing: 4) {
                            Text(currentGroup.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if isAdmin {
                        NavigationLink(destination: GroupSettingsView(group: currentGroup, isAdmin: true)) {
                            Image(systemName: "gear")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()

                TabView(selection: $selectedTab) {
                    FeedView(group: currentGroup, refreshTrigger: $feedRefreshTrigger)
                        .tabItem { Image(systemName: "newspaper") }
                        .tag(0)

                    LeaderboardView(group: currentGroup)
                        .tabItem { Image(systemName: "trophy") }
                        .tag(1)

                    Color.clear
                        .tabItem { Image(systemName: "plus.circle.fill") }
                        .tag(2)

                    SearchView(group: currentGroup)
                        .tabItem { Image(systemName: "magnifyingglass") }
                        .tag(3)

                    MyProfileView(group: currentGroup)
                        .tabItem { Image(systemName: "person") }
                        .tag(4)
                }
                .onChange(of: selectedTab) {
                    if selectedTab == 2 {
                        showNewPost = true
                        selectedTab = 0
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isAdmin = supabase.auth.currentUser?.id == currentGroup.createdBy
            }
        }
        .sheet(isPresented: $showNewPost) {
            NewPostView(group: currentGroup, onPost: {
                feedRefreshTrigger.toggle()
            })
        }
    }
}

#Preview {
    ContentView(currentGroup: GroupModel(
        id: UUID(),
        name: "Study Group",
        createdBy: UUID(),
        joinCode: "ABC123",
        createdAt: Date()
    ))
}
