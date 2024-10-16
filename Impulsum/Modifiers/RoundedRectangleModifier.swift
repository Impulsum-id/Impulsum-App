//
//  RoundedRectangleModifier.swift
//  Impulsum-AR
//
//  Created by Lucky on 13/10/24.
//

import SwiftUI

struct RoundedRectangleModifier: ViewModifier {
    
    var height: CGFloat
    var cornerRadius: CGFloat
    var material: Material
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        .shadow(.inner(color: Color.black.opacity(0.1), radius: 4, x: 1, y: 1.5))
                        .shadow(.inner(color: Color.black.opacity(0.08), radius: 4, x: 1, y: 1.5))
                        .shadow(.inner(color: Color.white.opacity(0.25), radius: 1, x: 0, y: -0.5))
                        .shadow(.inner(color: Color.white.opacity(0.3), radius: 1, x: 0, y: -0.5))
                    )
                    .foregroundStyle(material)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            )
    }
}

extension View {
    func roundedRectangleStyle(height: CGFloat, cornerRadius: CGFloat, material: Material) -> some View {
        self.modifier(RoundedRectangleModifier(height: height, cornerRadius: cornerRadius, material: material))
    }
}


