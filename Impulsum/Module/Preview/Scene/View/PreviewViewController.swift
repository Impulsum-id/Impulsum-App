// 
//  PreviewViewController.swift
//  Impulsum-app
//
//  Created by robert theo on 27/09/24.
//

import UIKit
import Combine

internal class PreviewViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: PreviewViewModel!
    private var cancelables = Set<AnyCancellable>()

    // MARK: - Publisher
    private let didLoadPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization Method
    static func create(
        with viewModel: PreviewViewModel
    ) -> PreviewViewController {
        let vc = PreviewViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
    }
    
    deinit {
        cancelables.forEach { $0.cancel() }
        cancelables.removeAll()
    }

    // MARK: - Setup
    private func setupView() {

    }

    // MARK: - Bind View Model
    private func bindViewModel() {
        let input = PreviewViewModel.Input(
            didLoad: didLoadPublisher
        )

        viewModel.bind(input)
        bindViewModelOutput()
    }

    private func bindViewModelOutput() {
        viewModel.output.$result
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }

            }
            .store(in: &cancelables)
    }
}
