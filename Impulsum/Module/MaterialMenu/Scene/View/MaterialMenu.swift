//
//  MaterialMenuView.swift
//  Impulsum-AR
//
//  Created by Lucky on 14/10/24.
//

import SwiftUI

struct MaterialMenuView: View {
    
    @EnvironmentObject var keyboardManager: KeyboardManager
    
    @State private var selectedButton: Int = 1
    @State private var selectedIndex: Int = 0
    
    @Binding var showSettings: Bool
    @Binding var selectedImageName: String?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                if selectedButton == 1 {
                    SettingsHeaderView(headerTitle: "Material Selection", onClose: { 
                        showSettings = false
                    })
                    
                    CustomSegmentedControlView(segments: ["Material", "Size"], selectedIndex: $selectedIndex)
                        .animation(nil, value: selectedIndex)
                    
                    switch selectedIndex {
                    case 0:
                        MaterialView(selectedImageName: $selectedImageName)
                            .transition(.identity)
                    case 1:
                        MaterialSizeView()
                            .transition(.identity)
                    default:
                        EmptyView()
                    }
                    
                } else if selectedButton == 2 {
                    SettingsHeaderView(headerTitle: "Saved Material", onClose: { 
                        showSettings = false
                    })
                    
                    // TODO: Save Material View(Sudah ada)
                }
                
                HStack(spacing: 15) {
                    CustomCircleButtonView(width: 55, height: 55, iconName: "square.on.square.intersection.dashed", isSelected: selectedButton == 1, isSystemImage: true) {
                        selectedButton = 1
                    }
                    
                    
                    // Temporarily disabled for now. 
                    // For next iteration
                    
                    // CustomCircleButtonView(width: 55, height: 55, iconName: "heart.fill", isSelected: selectedButton == 2, isSystemImage: true) {
                    //     selectedButton = 2
                    // }
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .frame(width: 363)
            .background(BlurView(style: .systemUltraThinMaterialDark))
            .clipShape(RoundedRectangle(cornerRadius: 29.5))
            .overlay(
                RoundedRectangle(cornerRadius: 29.5)
                    .inset(by: 0.45)
                    .stroke(.white.opacity(0.3), lineWidth: 0.9)
            )
        }
        .animation(.smooth, value: selectedIndex)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    MaterialMenuView(showSettings: .constant(true), selectedImageName: .constant("GrigoTexture"))
}
