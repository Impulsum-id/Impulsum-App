//
//  Impulsum_appApp.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import SwiftUI

@main
struct Impulsum_appApp: App {
    
    @StateObject private var keyboardManager = KeyboardManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyboardManager)
        }
    }
}
