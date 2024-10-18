//
//  ARViewController.swift
//  Impulsum-AR
//
//  Created by Dason Tiovino on 04/10/24.
//

import SwiftUI
import FocusEntity
import RealityKit
import ARKit
import SceneKit
import Combine


class ARViewController: UIViewController,ARSessionDelegate{
    var materialManager: MaterialSelectionManager?
    
    var modelEntities: [ModelEntity] = []
    var tapeEntities: [ModelEntity] = []
    var buttonEntity: ModelEntity? = nil
    var meshEntity: ModelEntity? = nil
    
    var distanceBetweenTwoPoints = 0
    var lockDistanceThreshold:Float = 0.1
    
    var textureName: String = "dummy_texture"
    var tileWidth: Float = 50.0
    var tileHeight: Float = 50.0
    var borderWidth: CGFloat = 2.0
    
    private var cancellable: (any Cancellable)?
    private var focusEntity: FocusEntity!
    private var arView: ARView!
    private var texture: TextureResource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.isLightEstimationEnabled = true
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        arView.session.run(config)
        
        let textureActive = try! TextureResource.load(named: "focusActive")
        let textureDisable = try! TextureResource.load(named: "focusDisable")
        
        focusEntity = FocusEntity(
            on: arView,
            style: .colored(
                onColor: MaterialColorParameter.texture(textureActive),
                offColor: MaterialColorParameter.texture(textureDisable),
                nonTrackingColor: MaterialColorParameter.texture(textureDisable),
                mesh: MeshResource.generatePlane(width: 0.1, depth: 0.1)
            )
        )
        
        self.texture = loadTextureResource(named: "dummy_texture")
        
        NotificationCenter.default.addObserver(forName: .placeModel, object: nil, queue: .main) { _ in
            self.placeModel(in: self.arView, focusEntity: self.focusEntity)
        }
        
        NotificationCenter.default.addObserver(forName: .undoModel, object: nil, queue: .main) { _ in
            self.undoModel()
        }
        
        NotificationCenter.default.addObserver(forName: .resetModel, object: nil, queue: .main) { _ in
            self.resetModel()
        }
        
        NotificationCenter.default.addObserver(forName: .changeMeshTexture, object: nil, queue: .main) { [weak self] notification in
            if let newTextureName = notification.object as? String {
                
                if newTextureName != self?.textureName {
                    self?.textureName = newTextureName
                    self?.tileWidth = 50
                    self?.tileHeight = 50
                    self?.borderWidth = CGFloat(2.0)
                    
                    self?.updateMeshTexture()
                } else {
                    self?.textureName = newTextureName
                    self?.updateMeshTexture()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .updateWidth, object: nil, queue: .main) { [weak self] notification in
            if let width = notification.object as? Float {
                self?.tileWidth = width
                self?.updateMeshTexture()
                print("Updated tile width: \(width)")
            }
        }

        NotificationCenter.default.addObserver(forName: .updateLength, object: nil, queue: .main) { [weak self] notification in
            if let length = notification.object as? Float {
                self?.tileHeight = length
                self?.updateMeshTexture()
                print("Updated tile height: \(length)")
            }
        }

        NotificationCenter.default.addObserver(forName: .updateGrout, object: nil, queue: .main) { [weak self] notification in
            if let grout = notification.object as? Float {
                self?.borderWidth = CGFloat(grout)
                self?.updateMeshTexture()
                print("Updated border width: \(grout)")
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    /// Place Model and check if there is any object nearby to lock the position
    /// on that object position to make the mesh
    func placeModel(in arView: ARView, focusEntity: FocusEntity?) {
        guard let focusEntity = focusEntity, self.meshEntity == nil else { return }
        var isLockedEntity:ModelEntity?

        // Validate Lock Entity
        if let pivotModelEntity = modelEntities.first{
            let pivotModelPosition = pivotModelEntity.position(relativeTo: nil)
            let distanceToModel = simd_distance(focusEntity.position, pivotModelPosition)
            
            if distanceToModel < lockDistanceThreshold {
                isLockedEntity = pivotModelEntity
            }
        }
        
        
        // Draw Entity
        let entity = ModelEntity(
            mesh: MeshResource.generatePlane(width: 0.015, depth: 0.015, cornerRadius: 50),
            materials: [UnlitMaterial(color: .white)]
        )
        let focusTransform = focusEntity.transformMatrix(relativeTo: nil)
        self.modelEntities.append(entity)
        
        let anchorEntity = AnchorEntity(world: isLockedEntity?.transformMatrix(relativeTo: nil) ?? focusTransform )
        anchorEntity.addChild(modelEntities[self.modelEntities.count - 1])
        arView.scene.addAnchor(anchorEntity)
        
        // Draw Line
        let modelsLength = self.modelEntities.count
        if(modelsLength >= 2){
            let positionA = modelEntities[modelsLength-2].position(relativeTo: nil)
            let positionB = modelEntities[modelsLength-1].position(relativeTo: nil)
            
            drawLine(from: positionA, to: positionB, distance: distance(positionA, positionB))
        }
                
        // Draw Mesh
        let modelsPoints = self.modelEntities.map{$0.position(relativeTo: nil)}
        if(isDrawable(in: modelsPoints)){
            let newPoints: [SIMD3<Float>] =  modelsPoints.dropLast()
            
            let modelEntity = drawMesh(from: newPoints)
            
            // Draw Button
            let centroid = calculateCentroid(of: newPoints)
            let buttonEntity = createButtonEntity(at: centroid)
            self.buttonEntity = buttonEntity
            
            // Append Mesh & Button to Anchor
            let anchor = AnchorEntity(world: self.modelEntities.first!.position)
            guard modelEntity != nil else {
                return print("Error: Mesh not created")
            }
            
            anchor.addChild(modelEntity!)
            anchor.addChild(buttonEntity)
            arView.scene.addAnchor(anchor)
        }
    }
    
    /// Check For Duplicates
    func isDrawable(in points: [SIMD3<Float>]) -> Bool{
        return points.first == points.last
    }
    
    func hasDuplicatePoints(in points: [SIMD3<Float>]) -> Bool {
        for i in 0..<points.count {
            for j in (i + 1)..<points.count {
                if points[i] == points[j] {
                    return true
                }
            }
        }
        return false
    }
    
    func undoModel(){
        guard !modelEntities.isEmpty && modelEntities.first != nil else {
            print("No more entities to undo.")
            return
        }
        
        // Remove Point
        let lastPoint = modelEntities.removeLast()
        lastPoint.removeFromParent()
        
    
        guard tapeEntities.count >= 2 else {
            return
        }
        
        // Remove Tape & Text
        tapeEntities[(tapeEntities.count-2)...].forEach{ entity in
            tapeEntities.removeLast()
            entity.removeFromParent()
        }
        
        guard meshEntity != nil || buttonEntity != nil else {
            return
        }
        
        buttonEntity?.removeFromParent()
        meshEntity?.removeFromParent()
        buttonEntity = nil
        meshEntity = nil
    }
    
    func resetModel(){
        modelEntities.forEach{$0.removeFromParent()}
        modelEntities = []
        
        tapeEntities.forEach{$0.removeFromParent()}
        tapeEntities = []
        
        buttonEntity?.removeFromParent()
        meshEntity?.removeFromParent()
        buttonEntity = nil
        meshEntity = nil
    }
    
    /// Draw Line using start & end position
    func drawLine(from start: SIMD3<Float>, to end: SIMD3<Float>, distance: Float) {
        let vector = end - start
        let length = simd_length(vector)
        
        let boxMesh = MeshResource.generateBox(size: [0.002, 0.002, length])
        let material = UnlitMaterial(color: .white)
        let lineEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        lineEntity.position = (start + end) / 2.0
        lineEntity.look(at: end, from: lineEntity.position, relativeTo: nil)
        
        // Format the distance text
        let distanceText = String(format: "%.2f m", distance)
        let textMesh = MeshResource.generateText(
            distanceText,
            extrusionDepth: 0,
            font: .systemFont(ofSize: 0.04),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = UnlitMaterial(color: .black)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        textEntity.position = (start + end) / 2.0
        textEntity.position.y += 0.02
        
        // Rotate the text to face upward (parallel to the floor)
        textEntity.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(-1, 0, 0))
        
        tapeEntities.append(lineEntity)
        tapeEntities.append(textEntity)
        
        let anchor = AnchorEntity()
        anchor.addChild(lineEntity)
        anchor.addChild(textEntity)
        arView.scene.addAnchor(anchor)
    }
    
    /// Draw Mesh from all of the object position
    func drawMesh(from points: [SIMD3<Float>]) -> ModelEntity? {
        
        guard points.count >= 3 else {
            print("Not enough points to form a mesh")
            return nil
        }
        
        let indices: [UInt32] = generateMesh(points)
        var meshDescriptor = MeshDescriptor()
        meshDescriptor.positions = MeshBuffers.Positions(points)
        
        let textureCoordinates = points.map { SIMD2<Float>($0.x, $0.z)}
        meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(textureCoordinates)
        
        let normals = points.map { _ in SIMD3<Float>(0, 1, 0) } // Adjusted normal direction
        meshDescriptor.normals = MeshBuffers.Normals(normals)
        meshDescriptor.primitives = .triangles(indices)
        
        let mesh: MeshResource
        do {
            mesh = try MeshResource.generate(from: [meshDescriptor])
        } catch {
            print("Failed to generate mesh: \(error)")
            return ModelEntity()
        }
        
        var material = PhysicallyBasedMaterial()
        let baseColor = MaterialParameters.Texture(texture)
        material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: baseColor)
        let scaleFactor: Float = 0.01
        let tileWidth: Float = 50 * scaleFactor
        let tileHeight: Float = 50 * scaleFactor
        material.textureCoordinateTransform.scale = SIMD2<Float>(1.0 / tileWidth, 1.0 / tileHeight)
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.5)
        material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 1.5)
        material.emissiveIntensity = 3.0
        
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        self.meshEntity = modelEntity
        
        return modelEntity
    }
    
    func createButtonEntity(at position: SIMD3<Float>) -> ModelEntity {
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
    
    func updateMeshTexture() {
        guard let newTexture = loadTextureResource(named: textureName, borderWidth: borderWidth) else {
            print("Failed to load texture: \(textureName)")
            return
        }
        var material = PhysicallyBasedMaterial()
        let baseColor = MaterialParameters.Texture(newTexture)
        material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: baseColor)
        
        let scaleFactor: Float = 0.01
        let tileWidth: Float = tileWidth * scaleFactor
        let tileHeight: Float = tileHeight * scaleFactor
        
        material.textureCoordinateTransform.scale = SIMD2<Float>(1.0 / tileWidth, 1.0 / tileHeight)
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.5)
        material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 1.5)
        material.emissiveIntensity = 3.0
        
        meshEntity?.model?.materials = [material]
    }
    
    func setupBillboard(for entity: Entity, in arView: ARView) {
        cancellable = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak arView, weak entity] event in
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let arView = sender.view as! ARView
        let location = sender.location(in: arView)
        
        guard materialManager != nil else { return }
        
        if let tappedEntity = arView.entity(at: location) {
            if entityContainsName(tappedEntity, name: "buttonEntity") {
                materialManager?.showSettings.toggle()
            }
        }
    }
}

