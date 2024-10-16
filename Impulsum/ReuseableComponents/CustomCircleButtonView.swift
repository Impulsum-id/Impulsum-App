//
//  CustomCircleButtonView.swift
//  Impulsum-AR
//
//  Created by Lucky on 09/10/24.
//

import SwiftUI

struct CustomCircleButtonView: View {
    
    var width: CGFloat
    var height: CGFloat
    var iconName: String
    var isSelected: Bool
    var isSystemImage: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                
                Circle()
                    .fill(isSelected ? Color(red: 0.76, green: 0.28, blue: 0.04).opacity(0.25) : Color.clear)
                    .frame(width: width, height: height)
                    .background(Circle().fill(.ultraThinMaterial))
                    .overlay(
                        Circle()
                            .inset(by: 0.57)
                            .stroke(.white.opacity(0.4), lineWidth: 1.14)
                    )
                
                if isSystemImage {
                    Image(systemName: iconName)
                        .font(.system(size: 25, weight: .medium))
                        .foregroundColor(.white.opacity(0.96))
                } else {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 39, height: 39)
                }
            }
        }
        .clipShape(Circle())
        .buttonStyle(PlainButtonStyle())
    }
}

//#Preview {
//    CustomCircleButtonView(iconName: "square.on.square.intersection.dashed", isSelected: true) { 
//        print("pressed")
//    }
//}

#Preview {
    MaterialMenuView(showSettings: .constant(true), selectedImageName: .constant("GrigoTexture"))
}
