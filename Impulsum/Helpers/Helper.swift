//
//  Helper.swift
//  SharePlate
//
//  Created by robert theo on 19/08/24.
//

import Foundation
import simd
import RealityFoundation
import UIKit
import RealityKit
import Combine

var defaultTimePickup: Date {
    var components = DateComponents()
    components.year = Calendar.current.component(.year, from: Date())
    components.month = Calendar.current.component(.month, from: Date())
    components.day = Calendar.current.component(.day, from: Date())
    components.hour  = Calendar.current.component(.hour, from: Date()) + 1
    components.minute = Calendar.current.component(.minute, from: Date())
    return Calendar.current.date(from: components) ?? .now
}

let startDate = Date(timeIntervalSinceNow: -24.0 * 3600.0)
let endDate = Date(timeIntervalSinceNow: 24.0 * 3600.0)

func computeSignedArea(_ points: [SIMD3<Float>]) -> Float {
    var area: Float = 0.0
    let n = points.count
    for i in 0..<n {
        let p1 = points[i]
        let p2 = points[(i + 1) % n]
        area += (p1.x * p2.z - p2.x * p1.z)
    }
    return area * 0.5
}

func isConvex(_ prev: SIMD3<Float>, _ curr: SIMD3<Float>, _ next: SIMD3<Float>) -> Bool {
    let d1 = SIMD2<Float>(curr.x - prev.x, curr.z - prev.z)
    let d2 = SIMD2<Float>(next.x - curr.x, next.z - curr.z)
    let cross = d1.x * d2.y - d1.y * d2.x
    return cross > 0
}

func isPointInTriangle(_ p: SIMD2<Float>, _ a: SIMD2<Float>, _ b: SIMD2<Float>, _ c: SIMD2<Float>) -> Bool {
    let v0 = c - a
    let v1 = b - a
    let v2 = p - a

    let dot00 = simd_dot(v0, v0)
    let dot01 = simd_dot(v0, v1)
    let dot02 = simd_dot(v0, v2)
    let dot11 = simd_dot(v1, v1)
    let dot12 = simd_dot(v1, v2)

    let invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01)
    let u = (dot11 * dot02 - dot01 * dot12) * invDenom
    let v = (dot00 * dot12 - dot01 * dot02) * invDenom
    return (u >= 0) && (v >= 0) && (u + v <= 1)
}

func generateMesh(_ points: [SIMD3<Float>]) -> [UInt32] {
    var indices: [UInt32] = []
    var vertexIndices = Array(0..<points.count)
    let area = computeSignedArea(points)

    if area < 0 {
        // Reverse indices for counter-clockwise orientation
        vertexIndices.reverse()
    }

    var remainingVertices = vertexIndices

    while remainingVertices.count > 3 {
        var earFound = false
        let n = remainingVertices.count
        for i in 0..<n {
            let prevIndex = remainingVertices[(i - 1 + n) % n]
            let currIndex = remainingVertices[i]
            let nextIndex = remainingVertices[(i + 1) % n]

            let prevPoint = points[prevIndex]
            let currPoint = points[currIndex]
            let nextPoint = points[nextIndex]

            if isConvex(prevPoint, currPoint, nextPoint) {
                var ear = true
                for j in 0..<n {
                    if j == (i - 1 + n) % n || j == i || j == (i + 1) % n {
                        continue
                    }
                    let pIndex = remainingVertices[j]
                    let pPoint = points[pIndex]
                    if isPointInTriangle(
                        SIMD2<Float>(pPoint.x, pPoint.z),
                        SIMD2<Float>(prevPoint.x, prevPoint.z),
                        SIMD2<Float>(currPoint.x, currPoint.z),
                        SIMD2<Float>(nextPoint.x, nextPoint.z)
                    ) {
                        ear = false
                        break
                    }
                }
                if ear {
                    indices.append(UInt32(prevIndex))
                    indices.append(UInt32(nextIndex))
                    indices.append(UInt32(currIndex))
                    
                    remainingVertices.remove(at: i)
                    earFound = true
                    break
                }
            }
        }
        if !earFound {
            print("No ear found; possible degenerate polygon")
            break
        }
    }

    if remainingVertices.count == 3 {
        indices.append(UInt32(remainingVertices[0]))
        indices.append(UInt32(remainingVertices[2]))
        indices.append(UInt32(remainingVertices[1]))
    }

    return indices
}

func calculateCentroid(of points: [SIMD3<Float>]) -> SIMD3<Float> {
    let sum = points.reduce(SIMD3<Float>(0, 0, 0), +)
    return sum / Float(points.count)
}

func entityContainsName(_ entity: Entity?, name: String) -> Bool {
    var currentEntity = entity
    while let entity = currentEntity {
        if entity.name == name {
            return true
        }
        currentEntity = entity.parent
    }
    return false
}

func loadTextureResource(named imageName: String, borderWidth: CGFloat = 2) -> TextureResource? {
    guard let uiImage = UIImage(named: imageName),
          let cgImage = uiImage.cgImage else {
        print("Failed to load image: \(imageName)")
        return nil
    }

    // Create a new image context with the desired size
    let newImageWidth = CGFloat(cgImage.width) + borderWidth * 2.0
    let newImageHeight = CGFloat(cgImage.height) + borderWidth * 2.0
    let newImageSize = CGSize(width: newImageWidth, height: newImageHeight)
    let newImageContext = CGContext(
        data: nil,
        width: Int(newImageWidth),
        height: Int(newImageHeight),
        bitsPerComponent: cgImage.bitsPerComponent,
        bytesPerRow: 0, space: cgImage.colorSpace!,
        bitmapInfo: cgImage.bitmapInfo.rawValue
    )!
    
    // Fill the new image context with the border color
    newImageContext.setFillColor(UIColor.black.cgColor)
    newImageContext.fill(CGRect(x: 0, y: 0, width: newImageWidth, height: newImageHeight))
    
    // Draw the original image centered in the new image context
    let imageRect = CGRect(x: borderWidth, y: borderWidth, width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
    newImageContext.draw(cgImage, in: imageRect)
    
    // Create a new CGImage from the new image context
    if let newCGImage = newImageContext.makeImage() {
        do {
            let texture = try TextureResource.generate(from: newCGImage, options: .init(semantic: nil))
            return texture
        } catch {
            print("Failed to create texture resource: \(error)")
            return nil
        }
    } else {
        print("Failed to create new CGImage")
        return nil
    }
}

func createButtonEntity(at position: SIMD3<Float>, in arView: ARView) -> ModelEntity {
    let buttonSize: Float = 0.15 // Adjust size as needed
    let buttonMesh = MeshResource.generatePlane(
        width: buttonSize,
        height: buttonSize,
        cornerRadius: buttonSize / 2
    )
    
    guard let iconImage = UIImage(named: "meshButton")?.cgImage else {
        print("Failed to load icon image")
        return ModelEntity()
    }
    
    do {
        let texture = try TextureResource.generate(
            from: iconImage,
            options: TextureResource.CreateOptions(semantic: .color)
        )
        
        var buttonMaterial = SimpleMaterial()
        buttonMaterial.baseColor = MaterialColorParameter.texture(texture)
        
        let buttonEntity = ModelEntity(mesh: buttonMesh, materials: [buttonMaterial])
        let rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        buttonEntity.orientation = rotation
        buttonEntity.position = SIMD3(x: position.x, y: position.y + 0.1, z: position.z + 0.1)
        buttonEntity.name = "buttonEntity"
        
        buttonEntity.generateCollisionShapes(recursive: true)
        
        setupBillboard(for: buttonEntity, in: arView)
        
        return buttonEntity
    } catch {
        print("Failed to create texture resource: \(error)")
        return ModelEntity()
    }
}

func setupBillboard(for entity: Entity, in arView: ARView) -> Cancellable {
    return arView.scene.subscribe(to: SceneEvents.Update.self) { [weak arView, weak entity] event in
        guard let arView = arView, let entity = entity else { return }
        
        guard let cameraTransform = arView.session.currentFrame?.camera.transform else {
            return
        }
        
        let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let entityPosition = entity.position(relativeTo: nil)
        let direction = normalize(cameraPosition - entityPosition)
        
        let up = SIMD3<Float>(0, 1, 0) // World up vector
        let right = normalize(cross(up, direction))
        let correctedUp = cross(direction, right)
        let rotationMatrix = float3x3(columns: (right, correctedUp, direction))
        entity.orientation = simd_quatf(rotationMatrix)
    }
}
