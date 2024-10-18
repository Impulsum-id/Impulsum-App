//
//  MaterialSelectionManager.swift
//  Impulsum
//
//  Created by Lucky on 17/10/24.
//

import SwiftUI

class MaterialSelectionManager: ObservableObject {
    @Published var showSettings:Bool = false
    @Published var selectedMaterialIndex: Int? = nil
}
