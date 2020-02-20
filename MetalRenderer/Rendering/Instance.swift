//
//  Instance.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

class Instance: Model {
    var transforms: [Transform]
    var instanceCount: Int
    var instanceBuffer: MTLBuffer
    
    init(name: String, instanceCount: Int = 1, findTangents: Bool = false) {
        transforms = [Transform](repeatElement(Transform(), count:  instanceCount))
        self.instanceCount = instanceCount
        instanceBuffer = Renderer.device.makeBuffer(length: instanceCount * MemoryLayout<Instances>.stride, options: [])!
        
        super.init(name: name, findTangents: findTangents)
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
        let mtkSubmesh = submesh.mtkSubmesh

        var pointer = instanceBuffer.contents().bindMemory(to: Instances.self, capacity: instanceCount)
        
        for transform in transforms {
            pointer.pointee.modelMatrix = transform.matrix
            pointer = pointer.advanced(by: 1)
        }
        commandEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 20)
        commandEncoder.setRenderPipelineState(submesh.instancedPipelineState)
//
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: mtkSubmesh.indexCount,
                                             indexType: mtkSubmesh.indexType,
                                             indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                             indexBufferOffset: mtkSubmesh.indexBuffer.offset,
                                             instanceCount: instanceCount)

    }
}
