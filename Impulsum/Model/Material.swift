//
//  Material.swift
//  Impulsum
//
//  Created by robert theo on 09/10/24.
//

import Foundation
import CloudKit

//internal struct Material: CloudKitableProtocol {
//    let id = UUID()
//    let name: String
//    let imageURL: URL?
//    let record: CKRecord
//
//    // This initializer should convert a CKRecord into a Material object
//    init?(record: CKRecord) {
//        // Ensure the record contains the needed fields
//        guard let name = record["name"] as? String else { return nil }
//        self.name = name
//        let imageAsset = record["image"] as? CKAsset
//        self.imageURL = imageAsset?.fileURL
//        self.record = record
//    }
//    
//    init?(name: String, imageURL: URL?) {
//        let record = CKRecord(recordType: "Materials")
//        record["name"] = name
//        if let url = imageURL {
//            let asset = CKAsset(fileURL: url)
//            record["image"] = asset
//        }
//    
//        self.init(record: record)
//    }


    // This computed property should return the CKRecord representation of the Material
//    var record: CKRecord {
//        let record = CKRecord(recordType: "Material")
//        if let url = imageURL {
//            let asset = CKAsset(fileURL: url)
//            record["image"] = asset
//        }
//        record["name"] = name as CKRecordValue
//        return record
//    }
//}

struct Material: Codable {
//    var id = UUID()
    let name: String
    let brand: String
    let color: String
    let size: String
    let image: String
}

struct MaterialsResponse: Codable {
    let materials: [Material]
}
