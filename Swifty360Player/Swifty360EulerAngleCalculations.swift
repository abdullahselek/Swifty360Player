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

let Swifty360EulerAngleCalculationNoiseThresholdDefault = CGFloat(0.12)
let Swifty360EulerAngleCalculationDefaultReferenceCompassAngle = Float(3.14)

let Swifty360EulerAngleCalculationRotationRateDampingFactor = Double(0.02)
let Swifty360EulerAngleCalculationYFovDefault = CGFloat(60.0)
let Swifty360EulerAngleCalculationYFovMin = CGFloat(40.0)
let Swifty360EulerAngleCalculationYFovMax = CGFloat(120.0)
let Swifty360EulerAngleCalculationYFovFunctionSlope = CGFloat(-33.01365882011044)
let Swifty360EulerAngleCalculationYFovFunctionConstant = CGFloat(118.599244406)

// MARK: Inline Functions

@inline(__always) func Swifty360EulerAngleCalculationResultMake(position: CGPoint, eulerAngles: SCNVector3) -> Swifty360EulerAngleCalculationResult {
    var result = Swifty360EulerAngleCalculationResult()
    result.position = position
    result.eulerAngles = eulerAngles
    return result
}

@inline(__always) func Swifty360AdjustPositionForAllowedAxes(position: CGPoint, allowedPanningAxes: Swifty360PanningAxis) -> CGPoint {
    var position = position
    let suppressXaxis = (UInt8(allowedPanningAxes.rawValue) & UInt8(Swifty360PanningAxis.horizontal.rawValue)) == 0
    let suppressYaxis = (UInt8(allowedPanningAxes.rawValue) & UInt8(Swifty360PanningAxis.vertical.rawValue)) == 0
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
    let eulerAngles = SCNVector3Make(position.y.getFloat(), position.x.getFloat(), 0)
    return Swifty360EulerAngleCalculationResult(position: position, eulerAngles: eulerAngles)
}

func Swifty360DeviceMotionCalculation(position: CGPoint,
                                      rotationRate: CMRotationRate,
                                      orientation: UIInterfaceOrientation,
                                      allowedPanningAxes: Swifty360PanningAxis,
                                      noiseThreshold: Double) -> Swifty360EulerAngleCalculationResult {
    var rotationRate = rotationRate

    if fabs(rotationRate.x) < noiseThreshold {
        rotationRate.x = 0
    }
    if fabs(rotationRate.y) < noiseThreshold {
        rotationRate.y = 0
    }

    var position = position
    if orientation.isLandscape {
        if orientation == .landscapeLeft {
            position = CGPoint(x: position.x + CGFloat(rotationRate.x * Swifty360EulerAngleCalculationRotationRateDampingFactor * -1),
                               y: position.y + CGFloat(rotationRate.y * Swifty360EulerAngleCalculationRotationRateDampingFactor))
        } else {
            position = CGPoint(x: position.x + CGFloat(rotationRate.x * Swifty360EulerAngleCalculationRotationRateDampingFactor),
                                   y: position.y + CGFloat(rotationRate.y * Swifty360EulerAngleCalculationRotationRateDampingFactor * -1))
        }
    } else {
        position = CGPoint(x: position.x + CGFloat(rotationRate.y * Swifty360EulerAngleCalculationRotationRateDampingFactor),
                           y: position.y - CGFloat(rotationRate.x * Swifty360EulerAngleCalculationRotationRateDampingFactor * -1))
    }
    position = CGPoint(x: position.x,
                       y: Swifty360Clamp(x: position.y, low: -.pi / 2, high: .pi / 2))
    position = Swifty360AdjustPositionForAllowedAxes(position: position, allowedPanningAxes: allowedPanningAxes)

    let eulerAngles = SCNVector3Make(position.y.getFloat(), position.x.getFloat(), 0)
    return Swifty360EulerAngleCalculationResultMake(position: position, eulerAngles: eulerAngles)
}

func Swifty360PanGestureChangeCalculation(position: CGPoint,
                                          rotateDelta: CGPoint,
                                          viewSize: CGSize,
                                          allowedPanningAxes: Swifty360PanningAxis) -> Swifty360EulerAngleCalculationResult {
    // The y multiplier is 0.4 and not 0.5 because 0.5 felt too uncomfortable.
    var position = CGPoint(x: position.x + 2 * .pi * rotateDelta.x / viewSize.width * 0.5,
                           y: position.y + 2 * .pi * rotateDelta.y / viewSize.height * 0.4)
    position.y = Swifty360Clamp(x: position.y, low: -.pi / 2, high: .pi / 2)
    position = Swifty360AdjustPositionForAllowedAxes(position: position, allowedPanningAxes: allowedPanningAxes)
    let eulerAngles = SCNVector3Make(position.y.getFloat(), position.x.getFloat(), 0)
    return Swifty360EulerAngleCalculationResultMake(position: position, eulerAngles: eulerAngles)
}

func Swifty360OptimalYFovForViewSize(viewSize: CGSize) -> CGFloat {
    var yFov: CGFloat!
    if viewSize.height > 0 {
        let ratio = viewSize.width / viewSize.height
        let slope = Swifty360EulerAngleCalculationYFovFunctionSlope
        yFov = (slope * ratio) + Swifty360EulerAngleCalculationYFovFunctionConstant
        yFov = min(max(yFov, Swifty360EulerAngleCalculationYFovMin), Swifty360EulerAngleCalculationYFovMax)
    } else {
        yFov = Swifty360EulerAngleCalculationYFovDefault
    }
    return yFov
}

func Swifty360CompassAngleForEulerAngles(eulerAngles: SCNVector3) -> Float {
    return Swifty360UnitRotationForCameraRotation(cameraRotation: (-1.0 * eulerAngles.y) + Swifty360EulerAngleCalculationDefaultReferenceCompassAngle)
}
