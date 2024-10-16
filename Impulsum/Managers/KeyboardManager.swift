//
//  KeyboardManager.swift
//  Impulsum
//
//  Created by Lucky on 15/10/24.
//

import SwiftUI
import Combine

class KeyboardManager: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in
                DispatchQueue.main.async {
                    self.isKeyboardVisible = true
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                DispatchQueue.main.async {
                    self.isKeyboardVisible = false
                }
            }
            .store(in: &cancellables)
    }
}

