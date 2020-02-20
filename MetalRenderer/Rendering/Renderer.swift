//
//  Renderer.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/10/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

//struct Vertex {
//    let position: SIMD3<Float>
//    let color: SIMD3<Float>
//}

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue

    static var library: MTLLibrary!

    let depthStencilState: MTLDepthStencilState
        
    weak var scene: Scene?
//    weak var titleScene: TitleScene?
//    let camera = ArcballCamera()
    
//    var uniforms = Uniforms()
//    var fragmentUniforms = FragmentUniforms()
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        
        view.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.createDepthState()

//        camera.target = [0, 0.8, 0]
//        camera.distance = 3
        super.init()
    }
    
    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene?.sceneSizeWillChange(to: size)
//        titleScene?.sceneSizeWillChange(to: size)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let scene = scene else {
                return
        }
        
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setDepthStencilState(depthStencilState)
        
        let deltaTime = 1/Float(view.preferredFramesPerSecond)
        scene.update(deltaTime: deltaTime)

        for renderable in scene.renderables {
            commandEncoder.pushDebugGroup(renderable.name)
            renderable.render(commandEncoder: commandEncoder,
                              uniforms: scene.uniforms,
                              fragmentUniforms: scene.fragmentUniforms)
            commandEncoder.popDebugGroup()
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
