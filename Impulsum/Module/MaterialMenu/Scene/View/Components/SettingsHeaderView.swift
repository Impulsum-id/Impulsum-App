//
//  SettingsHeaderView.swift
//  Impulsum-AR
//
//  Created by Lucky on 13/10/24.
//

import SwiftUI

struct SettingsHeaderView: View {
    
    var headerTitle: String
    var onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {                        
            Text(headerTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom(Fonts.SFProMedium, size: 15))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Button(action: {
                onClose()
            }) {
                Image(systemName: "xmark")
                    .font(.custom(Fonts.SFProMedium, size: 14))
                    .foregroundStyle(.white.opacity(0.96))
                    .frame(width: 28.2, height: 28.2, alignment: .center)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SettingsHeaderView(headerTitle: "Material Selection") { 
        print("pressed")
    }
}
