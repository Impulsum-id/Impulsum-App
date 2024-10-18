//
//  ContentView.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    @EnvironmentObject var keyboardManager: KeyboardManager
    @EnvironmentObject var materialManager: MaterialSelectionManager
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .environmentObject(materialManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                if !keyboardManager.isKeyboardVisible {
                    TabBarView(showSettings: $materialManager.showSettings)
                }
            }
            
            VStack(spacing: 0) {
                if materialManager.showSettings {
                    MaterialMenuView(showSettings: $materialManager.showSettings)
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
        .environmentObject(MaterialSelectionManager())
}
