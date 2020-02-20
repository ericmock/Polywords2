//
//  Common.h
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/11/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    float t;
    float lifespan;
} Uniforms;

typedef struct {
    vector_float3 cameraPosition;
} FragmentUniforms;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float shininess;
} Material;

typedef struct {
    matrix_float4x4 modelMatrix;
} Instances;

#endif /* Common_h */
