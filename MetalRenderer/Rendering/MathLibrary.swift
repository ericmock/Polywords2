/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import simd

let π = Float.pi

func radians(fromDegrees degrees: Float) -> Float {
    return (degrees / 180) * π
}

func degrees(fromRadians radians: Float) -> Float {
    return (radians / π) * 180
}

func pointInPolygon(withNumberOfPoints npol: Int, withXPoints xp: [Float], withYPoints yp: [Float], withX x: Float, withY y: Float) -> Bool {
    //int i, j, c = 0
    var j: Int = npol - 1
    var c: Bool = false
    for i in 0..<npol {
        //    for (i = 0, j = npol-1; i < npol; j = i++) {
        j = i
        if ((((yp[i] <= y) && (y < yp[j])) ||
            ((yp[j] <= y) && (y < yp[i]))) &&
            (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i])) {
            c = !c
        }
    }
    return c
}

extension float4x4 {
    
    // MARK: - Translate
    init(translateBy: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3.x = translateBy.x
        columns.3.y = translateBy.y
        columns.3.z = translateBy.z
    }
    
    // MARK: - Scale
    init(scaleBy: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.0.x = scaleBy.x
        columns.1.y = scaleBy.y
        columns.2.z = scaleBy.z
    }
    
    init(scaleBy: Float) {
        self = float4x4(scaleBy: SIMD3<Float>(scaleBy, scaleBy, scaleBy))
    }
    
    init(scaleByX: Float, scaleByY: Float, scaleByZ: Float) {
        self = float4x4(scaleBy: SIMD3<Float>(scaleByX, scaleByY, scaleByZ))
    }
    
    // MARK: - Rotate
    init(rotateAboutXBy angle: Float) {
        self = matrix_identity_float4x4
        columns.1.y = cos(angle)
        columns.1.z = sin(angle)
        columns.2.y = -sin(angle)
        columns.2.z = cos(angle)
    }
    
    init(rotateAboutYBy angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.z = -sin(angle)
        columns.2.x = sin(angle)
        columns.2.z = cos(angle)
    }
    
    init(rotateAboutZBy angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.y = sin(angle)
        columns.1.x = -sin(angle)
        columns.1.y = cos(angle)
    }
    
    init(rotateAboutXYZBy angle: SIMD3<Float>) {
        let rotationX = float4x4(rotateAboutXBy: angle.x)
        let rotationY = float4x4(rotateAboutYBy: angle.y)
        let rotationZ = float4x4(rotateAboutZBy: angle.z)
        self = rotationX * rotationY * rotationZ
    }
    
    init(rotateAboutXYZBy angle: SIMD3<Float>, aboutPoint: SIMD3<Float>) {
        let translate1 = float4x4(translateBy: aboutPoint)
        let translate2 = -translate1

        let rotationX = float4x4(rotateAboutXBy: angle.x)
        let rotationY = float4x4(rotateAboutYBy: angle.y)
        let rotationZ = float4x4(rotateAboutZBy: angle.z)
        self = translate2 * rotationX * rotationY * rotationZ * translate1
    }
    
    init(rotateAboutYXZBy angle: SIMD3<Float>) {
        let rotationX = float4x4(rotateAboutXBy: angle.x)
        let rotationY = float4x4(rotateAboutYBy: angle.y)
        let rotationZ = float4x4(rotateAboutZBy: angle.z)
        self = rotationY * rotationX * rotationZ
    }
    
    // MARK: - Identity
    static var identity: float4x4 {
        let matrix: float4x4 = matrix_identity_float4x4
        return matrix
    }
    
    // MARK: - Upper left 3x3
    var upperLeft: float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }
    
    // MARK: - Left handed projection matrix
    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (far - near)
        let X = SIMD4<Float>( x,  0,  0,  0)
        let Y = SIMD4<Float>( 0,  y,  0,  0)
        let Z = SIMD4<Float>( 0,  0,  z, 1)
        let W = SIMD4<Float>( 0,  0,  z * -near,  0)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    
    // left-handed LookAt
    init(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) {
        let z = normalize(center - eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let w = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye))
        let X = SIMD4<Float>(x.x, y.x, z.x, 0)
        let Y = SIMD4<Float>(x.y, y.y, z.y, 0)
        let Z = SIMD4<Float>(x.z, y.z, z.z, 0)
        let W = SIMD4<Float>(w.x, w.y, w.z, 1)
        self.init()
        columns = (X, Y, Z, W)
    }
}

extension float4 {
    var xyz: SIMD3<Float> {
        get {
            return SIMD3<Float>(x, y, z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}

extension float2 {
    var xy: SIMD2<Float> {
        get {
            return SIMD2<Float>(x, y)
        }
        set {
            x = newValue.x
            y = newValue.y
        }
    }
}

