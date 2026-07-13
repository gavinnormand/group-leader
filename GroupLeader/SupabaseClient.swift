//
//  SupabaseClient.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://oqooxwsdvmtiuargamvj.supabase.co")!,
    supabaseKey: "sb_publishable_WLcj0Jx2_9eIi_3rPtGZrQ_MoFfu9Ie",
    options: SupabaseClientOptions(
        db: SupabaseClientOptions.DatabaseOptions(
            encoder: {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                return encoder
            }(),
            decoder: {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }()
        )
    )
)
