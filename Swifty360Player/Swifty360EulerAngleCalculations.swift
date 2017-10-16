//
//  Swifty360EulerAngleCalculations.swift
//  Swifty360Player
//
//  Copyright © 2017 Abdullah Selek. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SceneKit
import CoreMotion

struct Swifty360EulerAngleCalculationResult {
    var position: CGPoint!
    var eulerAngles: SCNVector3!
}

// MARK: Inline Functions

@inline(__always) func Swifty360EulerAngleCalculationResultMake(position: CGPoint, eulerAngles: SCNVector3) -> Swifty360EulerAngleCalculationResult {
    var result = Swifty360EulerAngleCalculationResult()
    result.position = position
    result.eulerAngles = eulerAngles
    return result
}

@inline(__always) func Swifty360AdjustPositionForAllowedAxes(position: CGPoint, allowedPanningAxes: Swifty360PanningAxis) -> CGPoint {
    var position = position
    let suppressXaxis = allowedPanningAxes != .horizontal
    let suppressYaxis = allowedPanningAxes != .vertical
    if suppressXaxis == true {
        position.x = 0
    }
    if suppressYaxis == true {
        position.y = 0
    }
    return position
}

@inline(__always) func Swifty360UnitRotationForCameraRotation(cameraRotation: Float) -> Float {
    let oneRotation = Float(2.0 * .pi)
    let rawResult = fmodf(cameraRotation, oneRotation)
    let accuracy = Float(0.0001)
    let difference = Float(oneRotation - fabsf(rawResult))
    let wrappedAround = (difference < accuracy) ? 0 : rawResult
    return wrappedAround
}

@inline(__always) func Swifty360Clamp(x: CGFloat, low: CGFloat, high: CGFloat) -> CGFloat {
    return (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
}

// MARK: Calculations

func Swifty360UpdatedPositionAndAnglesForAllowedAxes(position: CGPoint,
                                                     allowedPanningAxes: Swifty360PanningAxis) -> Swifty360EulerAngleCalculationResult {
    let position = Swifty360AdjustPositionForAllowedAxes(position: position, allowedPanningAxes: allowedPanningAxes)
    let eulerAngles = SCNVector3Make(Float(position.y), Float(position.x), 0)
    return Swifty360EulerAngleCalculationResult(position: position, eulerAngles: eulerAngles)
}
