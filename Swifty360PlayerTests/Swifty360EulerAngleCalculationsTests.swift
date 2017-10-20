//
//  Swifty360EulerAngleCalculationsTests.swift
//  Swifty360PlayerTests
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

import XCTest
import CoreMotion

@testable import Swifty360Player

class Swifty360EulerAngleCalculationsTests: XCTestCase {
    
    func testUpdateFunctionShouldZeroOutDisallowedYAxis() {
        let position = CGPoint(x: 100, y: 100)
        let result = Swifty360UpdatedPositionAndAnglesForAllowedAxes(position: position, allowedPanningAxes: .horizontal)
        XCTAssertEqual(result.position.x, 100)
        XCTAssertEqual(result.position.y, 0)
    }

    func testUpdateFunctionShouldZeroOutDisallowedXAxis() {
        let position = CGPoint(x: 100, y: 100)
        let result = Swifty360UpdatedPositionAndAnglesForAllowedAxes(position: position, allowedPanningAxes: .vertical)
        XCTAssertEqual(result.position.x, 0)
        XCTAssertEqual(result.position.y, 100)
    }

    func testDeviceMotionFunctionShouldZeroOutDisallowedYAxis() {
        let position = CGPoint(x: 100, y: 100)
        var rate = CMRotationRate()
        rate.x = 1000
        rate.y = -1000
        rate.z = 10
        let orientation: UIInterfaceOrientation = .landscapeLeft
        let result = Swifty360DeviceMotionCalculation(position: position,
                                                      rotationRate: rate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: .horizontal,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        XCTAssertNotEqual(result.position.x, 0)
        XCTAssertEqual(result.position.y, 0)
    }

    func testDeviceMotionFunctionShouldZeroOutDisallowedXAxis() {
        let position = CGPoint(x: 100, y: 100)
        var rate = CMRotationRate()
        rate.x = 1000
        rate.y = -1000
        rate.z = 10
        let orientation: UIInterfaceOrientation = .landscapeLeft
        let result = Swifty360DeviceMotionCalculation(position: position,
                                                      rotationRate: rate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: .vertical,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        XCTAssertEqual(result.position.x, 0)
        XCTAssertNotEqual(result.position.y, 0)
    }

    func testDeviceMotionFunctionShouldFilterOutNegativeXRotationNoise() {
        let position = CGPoint(x: 100, y: 100)
        var rate = CMRotationRate()
        rate.x = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * -0.5
        rate.y = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * 2
        rate.z = 10
        let orientation: UIInterfaceOrientation = .landscapeLeft
        let result = Swifty360DeviceMotionCalculation(position: position,
                                                      rotationRate: rate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: .horizontal,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        XCTAssertEqual(result.position.x, position.x)
        XCTAssertNotEqual(result.position.y, position.y)
    }


    func testDeviceMotionFunctionShouldFilterOutPositiveXRotationNoise() {
        let position = CGPoint(x: 100, y: 100)
        var rate = CMRotationRate()
        rate.x = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * 0.5
        rate.y = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * 2
        rate.z = 10
        let orientation: UIInterfaceOrientation = .landscapeLeft
        let result = Swifty360DeviceMotionCalculation(position: position,
                                                      rotationRate: rate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: .horizontal,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        XCTAssertEqual(result.position.x, position.x)
        XCTAssertNotEqual(result.position.y, position.y)
    }

    func testDeviceMotionFunctionShouldFilterOutNegativeYRotationNoise() {
        let position = CGPoint(x: 100, y: 100)
        var rate = CMRotationRate()
        rate.x = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * 2
        rate.y = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * -0.5
        rate.z = 10
        let orientation: UIInterfaceOrientation = .landscapeLeft
        let result = Swifty360DeviceMotionCalculation(position: position,
                                                      rotationRate: rate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: .horizontal,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        XCTAssertNotEqual(result.position.x, 0)
        XCTAssertEqual(result.position.y, 0)
    }

    func testDeviceMotionFunctionShouldFilterOutPositiveYRotationNoise() {
        let position = CGPoint(x: 100, y: 100)
        var rate = CMRotationRate()
        rate.x = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * 2
        rate.y = Swifty360EulerAngleCalculationNoiseThresholdDefault.getDouble() * 0.5
        rate.z = 10
        let orientation: UIInterfaceOrientation = .landscapeLeft
        let result = Swifty360DeviceMotionCalculation(position: position,
                                                      rotationRate: rate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: .horizontal,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        XCTAssertNotEqual(result.position.x, 0)
        XCTAssertEqual(result.position.y, 0)
    }

    func testPanGestureChangeFunctionShouldZeroOutDisallowedYAxis() {
        let position = CGPoint(x: 100, y: 100)
        let delta = CGPoint(x: 1000, y: -1000)
        let viewSize = CGSize(width: 536, height: 320)
        let result = Swifty360PanGestureChangeCalculation(position: position,
                                                          rotateDelta: delta,
                                                          viewSize: viewSize,
                                                          allowedPanningAxes: .horizontal)
        XCTAssertNotEqual(result.position.x, 0)
        XCTAssertEqual(result.position.y, 0)
    }

    func testPanGestureChangeFunctionShouldZeroOutDisallowedXAxis() {
        let position = CGPoint(x: 100, y: 100)
        let delta = CGPoint(x: 1000, y: -1000)
        let viewSize = CGSize(width: 536, height: 320)
        let result = Swifty360PanGestureChangeCalculation(position: position,
                                                          rotateDelta: delta,
                                                          viewSize: viewSize,
                                                          allowedPanningAxes: .vertical)
        XCTAssertEqual(result.position.x, 0)
        XCTAssertNotEqual(result.position.y, 0)
    }

}
