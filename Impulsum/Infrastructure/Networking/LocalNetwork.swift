//
//  Network.swift
//  Impulsum
//
//  Created by robert theo on 14/10/24.
//

import Foundation

func loadJson<T: Decodable>(filename: String, as type: T.Type = T.self) -> T {
    let data: Data

    guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "json") else {
        fatalError("Couldn't find \(filename).json in main bundle.")
    }

    do {
        data = try Data(contentsOf: fileURL)
    } catch {
        fatalError("Couldn't load \(filename).json:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename).json:\n\(error)")
    }
}

