//
//  Network.swift
//  Impulsum
//
//  Created by robert theo on 14/10/24.
//

import Foundation
import SwiftUI

func loadImage(from urlString: URL?, completion: @escaping (UIImage?) -> Void) {
    guard let url = urlString else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Failed to load image: \(String(describing: error))")
            completion(nil)
            return
        }
        
        // Convert the data into UIImage
        if let uiImage = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(uiImage)
            }
        } else {
            print("Failed to convert data into UIImage")
            completion(nil)
        }
    }
    task.resume() // Start the data task
}
