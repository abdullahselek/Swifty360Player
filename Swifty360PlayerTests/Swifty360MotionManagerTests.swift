//
//  Swifty360MotionManagerTests.swift
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

import AVFoundation
import CoreMotion
import SceneKit
import UIKit
import XCTest

@testable import Swifty360Player

final class FakeMotionManagerDevice: Swifty360MotionManagerDevice {

    var isDeviceMotionAvailable = true
    var isDeviceMotionActive = false
    var deviceMotion: CMDeviceMotion?
    var deviceMotionUpdateInterval: TimeInterval = 0
    private(set) var startCount = 0
    private(set) var stopCount = 0

    func startDeviceMotionUpdates() {
        startCount += 1
        isDeviceMotionActive = true
    }

    func stopDeviceMotionUpdates() {
        stopCount += 1
        isDeviceMotionActive = false
    }

}

class Swifty360MotionManagerTests: XCTestCase {

    var motionManager: Swifty360MotionManager!
<<<<<<< HEAD
    private var motionDevice: FakeMotionManagerDevice!
=======
    var motionDevice: FakeMotionManagerDevice!
>>>>>>> d1eb059 (fix(motion): balance device motion observer lifecycle)

    override func setUp() {
        motionDevice = FakeMotionManagerDevice()
        motionManager = Swifty360MotionManager(motionManager: motionDevice)
    }

    override func tearDown() {
        motionManager = nil
        motionDevice = nil
    }

    func testInitiation() {
        XCTAssertNotNil(motionManager)
    }

    func testDeviceMotionAvailable() {
        XCTAssertTrue(motionManager.deviceMotionAvailable)
    }

    func testDeviceMotionActive() {
        let token = motionManager.startUpdating(preferredUpdateInterval: 1.0)
        XCTAssertTrue(motionManager.deviceMotionActive)
        motionManager.stopUpdating(token: token)
        XCTAssertFalse(motionManager.deviceMotionActive)
        XCTAssertEqual(motionDevice.stopCount, 1)
    }

    func testDeviceMotion() {
        XCTAssertNil(motionManager.deviceMotion)
    }

    func testStartUpdating() {
        let token = motionManager.startUpdating(preferredUpdateInterval: 2.0)
        motionManager.stopUpdating(token: token)
        XCTAssertNotNil(token)
    }

    func testStopUpdating() {
        let token = motionManager.startUpdating(preferredUpdateInterval: 2.0)
        motionManager.stopUpdating(token: token)
        XCTAssertEqual(motionManager.observerItems.count, 0)
        XCTAssertEqual(motionDevice.stopCount, 1)
    }

    func testDeviceMotionStopsOnlyAfterLastObserverLeaves() {
        let first = motionManager.startUpdating(preferredUpdateInterval: 1.0)
        let second = motionManager.startUpdating(preferredUpdateInterval: 2.0)

        XCTAssertEqual(motionDevice.startCount, 1)
        motionManager.stopUpdating(token: first)
        XCTAssertTrue(motionManager.deviceMotionActive)
        XCTAssertEqual(motionDevice.stopCount, 0)

        motionManager.stopUpdating(token: second)
        XCTAssertFalse(motionManager.deviceMotionActive)
        XCTAssertEqual(motionDevice.stopCount, 1)
    }

}

class Swifty360PlayerLifecycleTests: XCTestCase {

    func testViewBalancesMotionUpdatesAcrossWindowLifecycle() {
        let motionDevice = FakeMotionManagerDevice()
        let motionManager = Swifty360MotionManager(motionManager: motionDevice)
        let player = AVPlayer()
        let view = Swifty360View(
            withFrame: CGRect(x: 0, y: 0, width: 100, height: 100),
            player: player,
            motionManager: motionManager
        )
        view.setup(player: player, motionManager: motionManager)
        let window = UIWindow(frame: view.bounds)

        window.addSubview(view)
        XCTAssertEqual(motionDevice.startCount, 1)
        view.cameraController.startMotionUpdates()
        view.cameraController.startMotionUpdates()
        XCTAssertEqual(motionDevice.startCount, 1)

        view.removeFromSuperview()
        XCTAssertEqual(motionDevice.stopCount, 1)
        XCTAssertFalse(motionDevice.isDeviceMotionActive)

        window.addSubview(view)
        XCTAssertEqual(motionDevice.startCount, 2)
        view.removeFromSuperview()
        XCTAssertEqual(motionDevice.stopCount, 2)
    }

}
