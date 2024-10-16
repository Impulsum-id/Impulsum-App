//
//  MaterialView.swift
//  Impulsum-AR
//
//  Created by Lucky on 08/10/24.
//

import SwiftUI

struct MaterialView: View {
    
    let materialsResponse = loadJson(filename: "materials", as: MaterialsResponse.self)
    
    @Binding var selectedImageName: String?
    
    let gridLayout = [
        GridItem(.flexible(), alignment: .leading), 
        GridItem(.flexible()), 
        GridItem(.flexible(), alignment: .trailing)
    ]
    
    var body: some View {
        VStack(spacing: 0) { 
            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: 0) {
                    ForEach(materialsResponse.materials.indices, id: \.self) { index in
                        MaterialListView(
                            materialImageName: materialsResponse.materials[index].image,
                            materialBrand: materialsResponse.materials[index].brand,
                            materialName: materialsResponse.materials[index].name,
                            materialColor: materialsResponse.materials[index].color,
                            onMaterialTap: {
                                print("Tapped on: \(materialsResponse.materials[index].image)")
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .roundedRectangleStyle(height: 559, cornerRadius: 20, material: .thick) // Note ke koh jaya, height nya kalo bisa diganti jadi 559, sebelumnya 578
        .frame(height: 559)
    }
}



#Preview {
    MaterialView(selectedImageName: .constant("GrigoTexture"))
}
