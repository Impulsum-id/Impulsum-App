// 
//  PreviewResponseDTO.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import Foundation

internal struct PreviewResponseDTO: Decodable {
    
}

extension PreviewResponseDTO {
    func toDomain() -> PreviewModel {
        return .init()
    }
}
