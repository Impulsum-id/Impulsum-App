//
//  ARView.swift
//  Impulsum-AR
//
//  Created by Dason Tiovino on 04/10/24.
//

import ARKit
import UIKit
import SwiftUI

struct ARViewContainer: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARViewContainer>) -> ARViewController {
        let viewController = ARViewController()
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}
