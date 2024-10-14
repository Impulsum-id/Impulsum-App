//
//  ARViewController.swift
//  Impulsum-AR
//
//  Created by Dason Tiovino on 04/10/24.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import RealityGeometries

class ARViewController: UIViewController,ARSessionDelegate{
    var modelEntities: [ModelEntity] = []
    var tapeEntity: ModelEntity? = nil;
    var meshEntity: ModelEntity? = nil
    var distanceBetweenTwoPoints = 0;
    var lockDistanceThreshold:Float = 0.4;
    
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
        
//        self.texture = loadTextureResource(named: "tiled_dummy_texture")
        self.texture = loadTextureResource(named: "DefaultTexture")
        
//        self.texture = loadTextureResource()
        loadTextureResource() { textureResource in
            if let texture = textureResource {
                // Use the texture resourcez here
                self.texture = texture
                print("Successfully loaded texture resource")
            } else {
                print("Failed to load texture resource")
            }
        }

        NotificationCenter.default.addObserver(forName: .placeModel, object: nil, queue: .main) { _ in
            self.placeModel(in: self.arView, focusEntity: self.focusEntity)
        }
        
        NotificationCenter.default.addObserver(forName: .changeMeshTexture, object: nil, queue: .main) { [weak self] notification in
            if let newTextureName = notification.object as? String {
                self?.updateMeshTexture(named: newTextureName)
            }
        }
    }
    
    /// Place Model and check if there is any object nearby to lock the position
    /// on that object position to make the mesh
    func placeModel(in arView: ARView, focusEntity: FocusEntity?) {
        guard let focusEntity = focusEntity else { return }
        var isLockedEntity:ModelEntity?
        
        for modelEntity in modelEntities {
            let modelPosition = modelEntity.position(relativeTo: nil)
            let distanceToModel = simd_distance(focusEntity.position, modelPosition)
            
            if distanceToModel < lockDistanceThreshold {
                isLockedEntity = modelEntity
            }
        }
        
        do {
            let entity = try ModelEntity(
                mesh: MeshResource.generatePlane(width: 0.03, depth: 0.03, cornerRadius: 50),
                materials: [UnlitMaterial(color: .white)]
            )
            let focusTransform = focusEntity.transformMatrix(relativeTo: nil)
            self.modelEntities.append(entity)
            
            let anchorEntity = AnchorEntity(world: isLockedEntity?.transformMatrix(relativeTo: nil) ?? focusTransform )
            anchorEntity.addChild(modelEntities[self.modelEntities.count - 1])
            arView.scene.addAnchor(anchorEntity)
        } catch {
            print("Failed to load model: \(error)")
        }
        
        let modelsLength = self.modelEntities.count
        if(modelsLength >= 2){
            let positionA = modelEntities[modelsLength-2].position(relativeTo: nil)
            let positionB = modelEntities[modelsLength-1].position(relativeTo: nil)
            
            drawLine(from: positionA, to: positionB, distance: distance(positionA, positionB))
        }
        
        let modelsPoints = self.modelEntities.map{$0.position(relativeTo: nil)}
        if(hasDuplicatePoints(in: modelsPoints)){
            print("HAS DUPLICATE")
            let modelEntity = drawMesh(from: modelsPoints)
            let anchor = AnchorEntity(world: self.modelEntities.first!.position)
            if modelEntity != nil {
                anchor.addChild(modelEntity!)
                arView.scene.addAnchor(anchor)
            }
        }
        
    }
    
    /// Check For Duplicates
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
    
    /// Draw Line using start & end position
    func drawLine(from start: SIMD3<Float>, to end: SIMD3<Float>, distance: Float) {
        let vector = end - start
        let length = simd_length(vector)
        
        let boxMesh = MeshResource.generateBox(size: [0.01, 0.01, length])
        let material = UnlitMaterial(color: .white)
        let lineEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        lineEntity.position = (start + end) / 2.0
        lineEntity.look(at: end, from: lineEntity.position, relativeTo: nil)
        
        // Format the distance text
        let distanceText = String(format: "%.2f m", distance)
        let textMesh = MeshResource.generateText(distanceText, extrusionDepth: 0, font: .systemFont(ofSize: 0.04), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        var textMaterial = UnlitMaterial(color: .black)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        textEntity.position = (start + end) / 2.0
        textEntity.position.y += 0.02
        
        // Rotate the text to face upward (parallel to the floor)
        textEntity.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(-1, 0, 0))
        
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
        
        var indices: [UInt32] = []
        for i in 1...(points.count-3){
            indices.append(0)
            indices.append(UInt32(i))
            indices.append(UInt32(i + 1))
            
            indices.append(0)
            indices.append(UInt32(i + 1))
            indices.append(UInt32(i))
        }
        
        var meshDescriptor = MeshDescriptor()
        meshDescriptor.positions = MeshBuffers.Positions(points)
        print("Positions: ")
        print(points)
        
        let textureCoordinates = points.map { point in
            let x = point.x
            let z = point.z
            return SIMD2<Float>(x, z)
        }
        print("Texture Coordinates: ")
        print(textureCoordinates)
        meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(textureCoordinates)

        let normals = points.map { _ in SIMD3<Float>(0, 0, 1) }
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
        material.baseColor = PhysicallyBasedMaterial.BaseColor(texture:baseColor)
        material.textureCoordinateTransform.scale = SIMD2<Float>(2, 2)
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.5)
        material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 1.5)
        material.emissiveIntensity = 3.0
        
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        self.meshEntity = modelEntity
        
        return modelEntity
    }
    
//    func loadTextureResource(named imageName: String) -> TextureResource? {
//        guard let uiImage = UIImage(named: imageName),
//              let cgImage = uiImage.cgImage else {
//            print("Failed to load image: \(imageName)")
//            return nil
//        }
//        
//        let options = TextureResource.CreateOptions(semantic: .color, mipmapsMode: .allocateAndGenerateAll)
//        
//        do {
//            let texture = try TextureResource.generate(from: cgImage, options: options)
//            return texture
//        } catch {
//            print("Failed to create texture resource: \(error)")
//            return nil
//        }
//    }
    
    func loadTextureResource(completion: @escaping (TextureResource?) -> Void) {
//        var materials: [Material]
        let viewModel = HomeViewModel()
        
        viewModel.findAll { m in
//            materials = m
            // Process the materials here
            print("Retrieved materials: \(m)")
            guard let imageUrl = m[0].imageURL else {
                    print("Invalid image URL")
                    completion(nil)
                    return
            }

            
            loadImage(from: imageUrl) { uiImage in
                // Ensure the image is successfully loaded
                guard let uiImage = uiImage else {
                    print("Image loading failed")
                    completion(nil)
                    return
                }
                
                // Convert UIImage to CGImage
                guard let cgImage = uiImage.cgImage else {
                    print("Failed to convert UIImage to CGImage")
                    completion(nil)
                    return
                }
                
                // Set texture creation options
                let options = TextureResource.CreateOptions(semantic: .color, mipmapsMode: .allocateAndGenerateAll)
                
                do {
                    // Generate TextureResource from CGImage
                    let texture = try TextureResource.generate(from: cgImage, options: options)
                    DispatchQueue.main.async {
                        completion(texture)
                    }
                } catch {
                    print("Failed to create texture resource: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }

        
        
        
    }
    
    func updateMeshTexture(named imageName: String) {
        guard let newTexture = loadTextureResource(named: imageName) else {
            print("Failed to load texture: \(imageName)")
            return
        }

        var material = PhysicallyBasedMaterial()
        let baseColor = MaterialParameters.Texture(newTexture)
        material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: baseColor)
        material.textureCoordinateTransform.scale = SIMD2<Float>(2, 2)
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.5)
        material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 1.5)
        material.emissiveIntensity = 3.0

        meshEntity?.model?.materials = [material]
    }
}

