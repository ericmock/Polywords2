//
//  TitleScene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation


class TitleScene: Scene {

    let quadVertices:[SIMD4<Float>] = [
      SIMD4<Float>(1.0, 1.0, 0, 1),
      SIMD4<Float>(1.0, -1.0, 0, 1),
      SIMD4<Float>(-1.0, -1.0, 0, 1),
      SIMD4<Float>(1.0, 1.0, 0, 1),
      SIMD4<Float>(-1.0, -1.0, 0, 1),
      SIMD4<Float>(-1.0, 1.0, 0, 1)
    ]

    let quadUV:[SIMD2<Float>] = [
        SIMD2<Float>(1.0,1.0),
        SIMD2<Float>(1.0,0.0),
        SIMD2<Float>(0.0,0.0),
        SIMD2<Float>(1.0,1.0),
        SIMD2<Float>(0.0,0.0),
        SIMD2<Float>(0.0,1.0)
    ]
    
//    let title1 = Model(name: "Title1")
    let titles:[Model] = [Model(name: "Title1"),
                          Model(name: "Title2"),
                             Model(name: "Title3"),
                             Model(name: "Title4"),
                             Model(name: "Title5")]

    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 4
        camera.rotation = [-0.4, -0.4, 0]
//        add(node: title1)
//        title1.scaleV.y = 1.0/5.0
//        title1.position.x = 0.0
//        title1.position.y = 2.0
//        title1.position.z = 1.0
        
        for ii in 0..<titles.count {
            add(node: titles[ii])
            titles[ii].scaleV.y = 1/5
            titles[ii].position.x = 0.0
            titles[ii].position.y = -2.0 + Float(ii)/2


        }
    }
    
}
