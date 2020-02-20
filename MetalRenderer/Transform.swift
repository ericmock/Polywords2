//
//  Transform.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/11/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import simd

struct Transform {
    var position = SIMD3<Float>([0,0,0])
    var rotationV = SIMD3<Float>(repeating:0)
    var rotationM = float3x3(0)
    var scaleV = SIMD3<Float>(repeating:1)
    var scale: Float = 1

    var matrix: float4x4 {
        let translateMatrix = float4x4(translateBy: position)
        let rotationMatrix = float4x4(rotateAboutXYZBy: rotationV)
        let scaleMatrix = float4x4(scaleBy: scale)
        let nonUniformScaleMatrix = float4x4(scaleBy: scaleV)
        return translateMatrix * rotationMatrix * scaleMatrix * nonUniformScaleMatrix
    }
}
