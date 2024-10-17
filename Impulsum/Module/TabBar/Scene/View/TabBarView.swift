//
//  TabView.swift
//  Impulsum-AR
//
//  Created by Lucky on 08/10/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 78) {
            Button(action: {
                print("Back button tapped")
            }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 34, alignment: .center)
            }
            .disabled(true)
            
            Button(action: {
                NotificationCenter.default.post(name: .placeModel, object: nil)
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1, green: 0.46, blue: 0.19))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                        )
                    
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 6, height: 36)
                      .background(.white)
                      .cornerRadius(10)
                      .rotationEffect(Angle(degrees: 90))
                    
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 6, height: 36)
                      .background(.white)
                      .cornerRadius(10)
                }
            }
            
            Button(action: {
                showSettings.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 41, height: 17, alignment: .center)
            }
        }
        .padding(.vertical, 34).padding(.horizontal, 49)
        .frame(width: UIScreen.main.bounds.width, height: 94)
        .background(Color(red: 0.26, green: 0.26, blue: 0.26).opacity(0.68))
    }
}

#Preview {
    TabBarView(showSettings: .constant(false))
}
