// 
//  PreviewCoordinator.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import UIKit

public final class PreviewCoordinator {
    
    // MARK: - Properties
    private var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?
    ) {
        self.navigationController = navigationController
    }

    // MARK: - Private
    // Create View Controller
    private func makePreviewViewController() -> PreviewViewController {
        let repository = makePreviewRepository()
        let useCase = makePreviewUseCase(
            respository: repository
        )
        let viewModel = makePreviewViewModel(
            useCase: useCase
        )
        let viewController = PreviewViewController.create(
            with: viewModel
        )
        return viewController
    }
    
    // Create View Model
    private func makePreviewViewModel(
        useCase: PreviewUseCase
    ) -> PreviewViewModel {
        return PreviewViewModel(
            coordinator: self, 
            useCase: useCase
        )
    }
    
    // Create Use Case
    private func makePreviewUseCase(
        respository: PreviewRepository
    ) -> PreviewUseCase {
        return DefaultPreviewUseCase(
            repository: respository
        )
    }
    
    // Create Repository
    private func makePreviewRepository() -> PreviewRepository {
        return DefaultPreviewRepository()
    }
    
    // MARK: - Public
    // Entry Point
    func route() {
        
    }

    func create() -> PreviewViewController {
        let vc = makePreviewViewController()
        return vc
    }
}
