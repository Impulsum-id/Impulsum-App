//
//  MaterialSizeView.swift
//  Impulsum-AR
//
//  Created by Lucky on 13/10/24.
//

import SwiftUI

struct MaterialSizeView: View {
    
    @State private var width: String = ""
    @State private var length: String = ""
    @State private var grout: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) { 
                TextField("Width (cm)", text: $width)
                .font(.custom(Fonts.SFProMedium, size: 12))
                .padding(.horizontal, 20)
                .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
                .frame(height: 44)
                .padding(.vertical, 5)
                
                TextField("Length (cm)", text: $length)
                .font(.custom(Fonts.SFProMedium, size: 12))
                .padding(.horizontal, 20)
                .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
                .frame(height: 44)
                .padding(.vertical, 5)
            }
            
            TextField("Grout (mm)", text: $grout)
                .font(.custom(Fonts.SFProMedium, size: 12))
                .padding(.horizontal, 20)
                .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
                .frame(height: 44)
                .padding(.vertical, 5)
        }
        .keyboardType(.decimalPad)
    }
}

#Preview {
    MaterialSizeView()
}
