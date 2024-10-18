//
//  Supabase.swift
//  Impulsum
//
//  Created by robert theo on 18/10/24.
//

import Foundation
import Supabase

import Foundation

class SupabaseNetwork {

    // Computed property to get the API key from Info.plist
    var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }

    // Lazy initialization of the client to ensure apiKey is available when client is created
    lazy var client: SupabaseClient = {
        return SupabaseClient(supabaseURL: URL(string: "https://htkqxfbwwjfrqhqauzpb.supabase.co")!, supabaseKey: apiKey)
    }()
}
