//
//  RootView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

struct RootView: View {
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                ContentView()
            } else {
                AuthView()
            }
        }
        .task {
            for await state in supabase.auth.authStateChanges {
                isAuthenticated = state.session != nil
            }
        }
    }
}

#Preview {
    RootView()
}
