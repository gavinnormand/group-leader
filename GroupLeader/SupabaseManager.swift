//
//  SupabaseManager.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import Foundation
import Supabase

private func infoPlistValue(for key: String) -> String {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
        fatalError("Missing \(key) in Info.plist — check your xcconfig setup")
    }
    return value
}

let supabase = SupabaseClient(
    supabaseURL: URL(string: infoPlistValue(for: "SUPABASE_URL"))!,
    supabaseKey: infoPlistValue(for: "SUPABASE_KEY")
)
