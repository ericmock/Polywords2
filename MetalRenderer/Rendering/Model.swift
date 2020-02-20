//
//  Model.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/11/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

class Model: Node {

    let meshes: [Mesh]
//    var transform: Transform
//    var instanceCount: Int
//    var instanceBuffer: MTLBuffer
    var hasTangents: Bool = false
//    var modelBuffer: MTLBuffer
            
    init(name: String, findTangents: Bool = false) {
        let assetURL = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)

        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor(hasTangent: findTangents)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        
//        transform = Transform()

        asset.loadTextures()
        
        if findTangents {
            for sourceMesh in asset.childObjects(of: MDLMesh.self) as! [MDLMesh] {
                sourceMesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                           normalAttributeNamed: MDLVertexAttributeNormal,
                                           tangentAttributeNamed: MDLVertexAttributeTangent)
                sourceMesh.vertexDescriptor = vertexDescriptor
            }
            self.hasTangents = true
        }

        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1, findTangents: findTangents)
        }
        
        super.init()
        self.name = name
    }
    
//    func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
//        // override in Instances
//        let mtkSubmesh = submesh.mtkSubmesh
//
//        commandEncoder.drawIndexedPrimitives(type: .triangle,
//                                             indexCount: mtkSubmesh.indexCount,
//                                             indexType: mtkSubmesh.indexType,
//                                             indexBuffer: mtkSubmesh.indexBuffer.buffer,
//                                             indexBufferOffset: mtkSubmesh.indexBuffer.offset)
//    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
      let mtkSubmesh = submesh.mtkSubmesh
      commandEncoder.drawIndexedPrimitives(type: .triangle,
                                           indexCount: mtkSubmesh.indexCount,
                                           indexType: mtkSubmesh.indexType,
                                           indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                           indexBufferOffset: mtkSubmesh.indexBuffer.offset)
    }

//    func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
//        
//        var pointer = instanceBuffer.contents().bindMemory(to: Instances.self, capacity: instanceCount)
//
//        for transform in transforms {
//            pointer.pointee.modelMatrix = transform.matrix
//            pointer = pointer.advanced(by: 1)
//        }
//        
//        modelBuffer.modelMatrix = transform.matrix
//        commandEncoder.setVertexBuffer(modelBuffer, offset: 0, index: 20)
//        commandEncoder.setRenderPipelineState(submesh.instancedPipelineState)
//        
//        let mtkSubmesh = submesh.mtkSubmesh
//        
//        commandEncoder.drawIndexedPrimitives(type: .triangle,
//                                             indexCount: mtkSubmesh.indexCount,
//                                             indexType: mtkSubmesh.indexType,
//                                             indexBuffer: mtkSubmesh.indexBuffer.buffer,
//                                             indexBufferOffset: mtkSubmesh.indexBuffer.offset,
//                                             instanceCount: instanceCount)
//
//    }
}

extension Model: Renderable {
  func render(commandEncoder: MTLRenderCommandEncoder,
              uniforms vertex: Uniforms,
              fragmentUniforms fragment: FragmentUniforms) {
    var uniforms = vertex
    var fragmentUniforms = fragment

    uniforms.modelMatrix = worldMatrix
    commandEncoder.setVertexBytes(&uniforms,
                                  length: MemoryLayout<Uniforms>.stride,
                                  index: 21)
    commandEncoder.setFragmentBytes(&fragmentUniforms,
                                   length: MemoryLayout<FragmentUniforms>.stride,
                                   index: 22)
    
    for mesh in meshes {
      for vertexBuffer in mesh.mtkMesh.vertexBuffers {
        
        commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
        
        for submesh in mesh.submeshes {
          commandEncoder.setRenderPipelineState(submesh.pipelineState)
          var material = submesh.material
          commandEncoder.setFragmentBytes(&material,
                                          length: MemoryLayout<Material>.stride,
                                          index: 11)
          commandEncoder.setFragmentTexture(submesh.textures.baseColor, index: 0)
          let mtkSubmesh = submesh.mtkSubmesh
          
          commandEncoder.setRenderPipelineState(submesh.pipelineState)
          
          render(commandEncoder: commandEncoder, submesh: submesh)

//          commandEncoder.drawIndexedPrimitives(type: .triangle,
//                                               indexCount: mtkSubmesh.indexCount,
//                                               indexType: mtkSubmesh.indexType,
//                                               indexBuffer: mtkSubmesh.indexBuffer.buffer,
//                                               indexBufferOffset: mtkSubmesh.indexBuffer.offset)
        }
      }
    }

  }
}
