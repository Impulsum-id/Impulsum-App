// 
//  PreviewUseCase.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import Foundation
import Combine

protocol PreviewUseCase {
    func fetch() -> AnyPublisher<PreviewModel, Error>
}

internal final class DefaultPreviewUseCase: PreviewUseCase {
    private let repository: PreviewRepository
    
    init(
        repository: PreviewRepository
    ) {
        self.repository = repository
    }

    func fetch() -> AnyPublisher<PreviewModel, Error> {
        repository.fetch()
    }
}
