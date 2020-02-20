//
//  Mesh.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

struct Mesh {
    
    let mtkMesh: MTKMesh
    let submeshes: [Submesh]
    let findTangents: Bool
    
    init(mdlMesh: MDLMesh, mtkMesh: MTKMesh, findTangents: Bool) {
        self.findTangents = findTangents
        self.mtkMesh = mtkMesh
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map {
            Submesh(mdlSubmesh: $0.0 as! MDLSubmesh, mtkSubmesh: $0.1, findTangents: findTangents)
        }
    }
}

struct Submesh {
    let mtkSubmesh: MTKSubmesh
    var material: Material
    var hasTangents: Bool = false

    struct Textures {
        let baseColor: MTLTexture?
        
        init(material: MDLMaterial?) {
            guard let baseColor = material?.property(with: .baseColor),
            baseColor.type == .texture,
                let mdlTexture = baseColor.textureSamplerValue?.texture else {
                    self.baseColor = nil
                    return
            }
            let textureLoader = MTKTextureLoader(device: Renderer.device)
            let textureLoaderOptions: [MTKTextureLoader.Option:Any] = [.origin: MTKTextureLoader.Origin.bottomLeft]
            self.baseColor = try? textureLoader.newTexture(texture: mdlTexture, options: textureLoaderOptions)
        }
    }
    
    let textures: Textures
    let pipelineState: MTLRenderPipelineState
    let instancedPipelineState: MTLRenderPipelineState
    
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh, findTangents:  Bool) {
        //if meshName == "TestPolyhedron" {self.hasTangents = true}
        if findTangents {self.hasTangents = true}
        self.mtkSubmesh = mtkSubmesh
        material = Material(material: mdlSubmesh.material)
//        material
        textures = Textures(material: mdlSubmesh.material)
        pipelineState = Submesh.createPipelineState(vertexFunctionName: "vertex_main", textures: textures, hasTangents: self.hasTangents)
        instancedPipelineState = Submesh.createPipelineState(vertexFunctionName: "vertex_instances", textures: textures, hasTangents: self.hasTangents)
    }
    
    static func createPipelineState(vertexFunctionName: String, textures: Textures, hasTangents: Bool) -> MTLRenderPipelineState {
        let functionConstants = MTLFunctionConstantValues()
        var property = textures.baseColor != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 0)
        
        let vertexFunction = Renderer.library.makeFunction(name: vertexFunctionName)
        let fragmentFunction = try! Renderer.library.makeFunction(name: "fragment_main", constantValues: functionConstants)

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor(hasTangent: hasTangents)
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

private extension Material {
    init(material:  MDLMaterial?) {
        self.init()
        if let baseColor = material?.property(with: .baseColor),
            baseColor.type == .float3 {
            self.baseColor = baseColor.float3Value
        }
        if let specular = material?.property(with: .specular),
            specular.type == .float3 {
            self.specularColor = specular.float3Value
        }
        if let shininess = material?.property(with: .specularExponent),
            shininess.type == .float {
            self.shininess = shininess.floatValue
        }
    }
}
