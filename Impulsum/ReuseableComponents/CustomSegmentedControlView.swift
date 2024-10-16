//
//  CustomSegmentedControlView.swift
//  Impulsum-AR
//
//  Created by Lucky on 12/10/24.
//

import SwiftUI

struct CustomSegmentedControlView: View {
    
    var segments: [String]
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<segments.count, id: \.self) { index in
                    ZStack {
                        if selectedIndex == index {
                            Rectangle()
                                .fill(Color(red: 106/255, green: 41/255, blue: 9/255))
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.25)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color.white.opacity(0.4), location: 0.0),
                                                    .init(color: Color.white.opacity(0), location: 0.41),
                                                    .init(color: Color.white.opacity(0), location: 0.57),
                                                    .init(color: Color.white.opacity(0.1), location: 1.0)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                        }
                        
                        Text(segments[index])
                            .frame(maxWidth: .infinity)
                            .font(.custom(Fonts.SFProSemibold, size: 12))
                            .foregroundColor(selectedIndex == index ? .white.opacity(0.96) : .white.opacity(0.23))
                    }
                    .onTapGesture {
                        selectedIndex = index
                    }
                }
            }
            .frame(height: 36)
        }
        .padding(4)
        .roundedRectangleStyle(height: 44, cornerRadius: 100, material: .thickMaterial)
        .frame(width: 248, height: 44)
    }
}

#Preview {
    CustomSegmentedControlView(segments: ["Material", "Size"] , selectedIndex: .constant(0))
}

