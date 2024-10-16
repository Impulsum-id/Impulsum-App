//
//  ContentView.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    @EnvironmentObject var keyboardManager: KeyboardManager
    
    @State private var showSettings = false
    @State private var selectedImageName: String? = nil
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {                
                Spacer()
                
                if !keyboardManager.isKeyboardVisible {
                    TabBarView(showSettings: $showSettings)
                }
            }
            
            VStack(spacing: 0) {
                if showSettings {
                    MaterialMenuView(showSettings: $showSettings, selectedImageName: $selectedImageName)
                }
                
                Spacer()
            }

        }
        .preferredColorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(KeyboardManager())
}
