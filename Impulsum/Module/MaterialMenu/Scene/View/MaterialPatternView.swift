//
//  MaterialPatternView.swift
//  Impulsum-AR
//
//  Created by Lucky on 14/10/24.
//

import SwiftUI

struct MaterialPatternView: View {
    
    @State private var selectedButton: Int = 1
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 28) {
                CustomCircleButtonView(width: 75, height: 75, iconName: "Pattern1", isSelected: selectedButton == 1, isSystemImage: false) {
                    selectedButton = 1
                }
                
                CustomCircleButtonView(width: 75, height: 75, iconName: "Pattern2", isSelected: selectedButton == 2, isSystemImage: false) {
                    selectedButton = 2
                }
                
                CustomCircleButtonView(width: 75, height: 75, iconName: "Pattern2", isSelected: selectedButton == 3, isSystemImage: false) {
                    selectedButton = 3
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .frame(width: 282, height: 282)
    }
}

#Preview {
    MaterialPatternView()
}
