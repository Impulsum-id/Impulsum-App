//
//  MaterialListView.swift
//  Impulsum-AR
//
//  Created by Lucky on 12/10/24.
//

import SwiftUI

struct MaterialListView: View {
    
    let materialImageName: String
    let materialBrand: String
    let materialName: String
    let materialColor: String
    let isMaterialSelected: Bool
    let onMaterialTap: () -> Void
    
    var body: some View {
        Button(action: {
            onMaterialTap()
        }) {
            VStack(spacing: 7) {
                Image(materialImageName)
                    .resizable()
                    .frame(width: 71, height: 71)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isMaterialSelected ? Color(red: 1, green: 0.46, blue: 0.19) : Color.white, lineWidth: 3)
                    )
                
                Text(materialBrand)
                    .underline()
                    .font(.system(size: 10, weight: .semibold))
                    .font(.custom(Fonts.SFProSemibold, size: 10))
                    .foregroundColor(.white.opacity(0.23))
                
                Text(materialName)
                    .font(.custom(Fonts.SFProMedium, size: 8))
                    .foregroundColor(.white.opacity(0.23))
                
                Text(materialColor)
                    .font(.custom(Fonts.SFProSemibold, size: 6))
                    .foregroundColor(.white.opacity(0.23))
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MaterialListView(materialImageName: "GrigoTexture", materialBrand: "Roman", materialName: "Newcastle", materialColor: "Grigio", isMaterialSelected: true) { 
        print("tapped")
    }
}
