//
//  MaterialView.swift
//  Impulsum-AR
//
//  Created by Lucky on 08/10/24.
//

import SwiftUI

struct MaterialView: View {
    
    let materialsResponse = loadJson(filename: "materials", as: MaterialsResponse.self)
    
    let gridLayout = [
        GridItem(.flexible(), alignment: .leading), 
        GridItem(.flexible()), 
        GridItem(.flexible(), alignment: .trailing)
    ]
    
    @Binding var selectedMaterialIndex: Int?
    
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
                            isMaterialSelected: index == selectedMaterialIndex,
                            onMaterialTap: {
                                selectedMaterialIndex = index
                                
                                print("selected image: \(materialsResponse.materials[index].image)")
                                
                                NotificationCenter.default.post(name: .changeMeshTexture, object: materialsResponse.materials[index].image)
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
        .roundedRectangleStyle(height: 559, cornerRadius: 20, material: .regular)
        .frame(height: 559)
    }
}



#Preview {
    MaterialView(selectedMaterialIndex: .constant(0))
}
