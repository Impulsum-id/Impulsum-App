// 
//  PreviewRepository.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import Foundation
import Combine

protocol PreviewRepository {
    func fetch() -> AnyPublisher<PreviewModel, Error>
}

internal final class DefaultPreviewRepository: PreviewRepository {
    
    init() { }
    
    func fetch() -> AnyPublisher<PreviewModel, Error> {
        return Future<PreviewModel, Error> { promise in
            promise(.success(.init()))
        }
        .eraseToAnyPublisher()
    }
}
