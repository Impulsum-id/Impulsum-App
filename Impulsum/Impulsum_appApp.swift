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
    @StateObject private var materialSelectionManager = MaterialSelectionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyboardManager)
                .environmentObject(materialSelectionManager)
        }
    }
}
