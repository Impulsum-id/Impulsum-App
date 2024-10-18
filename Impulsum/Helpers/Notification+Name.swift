//
//  Notification+Name.swift
//  Impulsum-AR
//
//  Created by Dason Tiovino on 04/10/24.
//

import NotificationCenter

extension Notification.Name {
    static let placeModel = Notification.Name("placeModel")
    static let undoModel = Notification.Name("undoModel")
    static let resetModel = Notification.Name("resetModel")
    
    static let changeMeshTexture = Notification.Name("changeMeshTexture")
    static let updateWidth = Notification.Name("updateWidth")
    static let updateLength = Notification.Name("updateLength")
    static let updateGrout = Notification.Name("updateGrout")
}
