//
//  MaterialSizeView.swift
//  Impulsum-AR
//
//  Created by Lucky on 13/10/24.
//

import SwiftUI

struct MaterialSizeView: View {
    
    @State private var width: Float?
    @State private var length: Float?
    @State private var grout: Float?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) { 
                TextField("Width (cm)", value: $width, format: .number)
                .font(.custom(Fonts.SFProMedium, size: 12))
                .padding(.horizontal, 20)
                .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
                .frame(height: 44)
                .padding(.vertical, 5)
                .onChange(of: width, { oldValue, newValue in
                    if let newValue = newValue {
                        NotificationCenter.default.post(name: .updateWidth, object: newValue)
                    }
                })
                
                TextField("Length (cm)", value: $length, format: .number)
                .font(.custom(Fonts.SFProMedium, size: 12))
                .padding(.horizontal, 20)
                .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
                .frame(height: 44)
                .padding(.vertical, 5)
                .onChange(of: length, { oldValue, newValue in
                    if let newValue = newValue {
                        NotificationCenter.default.post(name: .updateLength, object: newValue)
                    }
                })
            }
            
            TextField("Grout (mm)", value: $grout, format: .number)
                .font(.custom(Fonts.SFProMedium, size: 12))
                .padding(.horizontal, 20)
                .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
                .frame(height: 44)
                .padding(.vertical, 5)
                .onChange(of: grout, { oldValue, newValue in
                    if let newValue = newValue {
                        NotificationCenter.default.post(name: .updateGrout, object: newValue)
                    }
                })
        }
        .keyboardType(.decimalPad)
    }
}

#Preview {
    MaterialSizeView()
}
