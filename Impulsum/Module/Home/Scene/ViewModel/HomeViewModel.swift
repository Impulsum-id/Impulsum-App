//
//  HomeViewModel.swift
//  Impulsum
//
//  Created by robert theo on 09/10/24.
//

import Foundation
import CloudKit
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var permissionStatus: Bool = false
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""

    
    @Published var materials: [Material] = []
    var cancellables = Set<AnyCancellable>()

    init() {
        getiCloudStatus()
        requestPermission()
        findAll()
    }
    
    enum CloudKitError: LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
    
    
    private func getiCloudStatus() {
        CKContainer.default().accountStatus() {
            [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self?.isSignedInToiCloud = true
                    break
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountUnknown.localizedDescription
                    break
                case  .couldNotDetermine:
                    self?.error = CloudKitError.iCloudAccountNotDetermined.localizedDescription
                    break
                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRestricted.localizedDescription
                    break
                default:
                    self?.error = CloudKitError.iCloudAccountUnknown.localizedDescription
                    break
                }
            }
        }
    }

    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [weak self]
            returnedStatus, returnedError in
            DispatchQueue.main.async {
                print(returnedStatus == .granted)
                if returnedStatus == .granted {
                    self?.permissionStatus = true
                }
            }
        }
    }

    
    func findAll() {
        let predicate = NSPredicate(value: true)
        let recordType = "Materials"
        
        CloudKitUtility.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedItems in
                self?.materials = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func addItem() {
        guard
            let image = UIImage(named: "MatchingFloor_Roman_Austin_White_50x50-768x768"),
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("MatchingFloor_Roman_Austin_White_50x50-768x768.jpg"),
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        do {
            try data.write(to: url)
            guard let material = Material(name: "Austin White", imageURL: url) else { return }
            CloudKitUtility.add(item: material) { result in
                
            }
        } catch let error {
            print(error)
        }
    }

}
