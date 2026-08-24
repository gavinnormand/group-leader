//
//  ContentView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/18/26.
//

import SwiftUI
import Supabase

struct ContentView: View {
    let group: GroupModel
    @Binding var selectedGroup: GroupModel?

    @State private var selectedTab = 0
    @State private var showNewPost = false
    @State private var refreshTrigger = false
    @State private var showGroups = false

    private var isAdmin: Bool { group.isAdmin }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        showGroups = true
                    } label: {
                        Image(systemName: "person.2")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Spacer()

                    Text(group.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if isAdmin {
                        NavigationLink(destination: GroupSettingsView(
                            group: group,
                            isAdmin: true,
                            onUpdate: { updatedGroup in
                                selectedGroup = updatedGroup
                                refreshTrigger.toggle()
                            },
                            onDelete: { selectedGroup = nil }
                        )) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    } else {
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()

                TabView(selection: $selectedTab) {
                    FeedView(group: group, refreshTrigger: $refreshTrigger)
                        .tabItem { Image(systemName: "newspaper") }
                        .tag(0)

                    LeaderboardView(group: group, refreshTrigger: $refreshTrigger)
                        .tabItem { Image(systemName: "trophy") }
                        .tag(1)

                    Color.clear
                        .tabItem { Image(systemName: "plus.circle.fill") }
                        .tag(2)

                    SearchView(group: group, refreshTrigger: $refreshTrigger)
                        .tabItem { Image(systemName: "magnifyingglass") }
                        .tag(3)

                    MyProfileView(group: group, refreshTrigger: $refreshTrigger)
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
        }
        .sheet(isPresented: $showNewPost) {
            NewPostView(group: group, onPost: {
                refreshTrigger.toggle()
            })
        }
        .sheet(isPresented: $showGroups) {
            NavigationStack {
                GroupsView(currentGroup: $selectedGroup)
            }
            .presentationBackground(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    ContentView(
        group: GroupModel(
            id: UUID(),
            name: "Study Group",
            createdBy: UUID(),
            joinCode: "ABC123",
            createdAt: Date()
        ),
        selectedGroup: .constant(nil)
    )
}
