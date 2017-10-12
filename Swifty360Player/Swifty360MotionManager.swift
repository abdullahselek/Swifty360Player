//
//  Swifty360MotionManager.swift
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

import CoreMotion

public protocol Swifty360MotionManagement {

    var deviceMotionAvailable: Bool { get }
    var deviceMotionActive: Bool { get }
    var deviceMotion: CMDeviceMotion? { get }

    func startUpdating(preferredUpdateInterval: TimeInterval) -> NSUUID
    func stopUpdating(token: NSUUID)

}

open class Swifty360MotionManager: Swifty360MotionManagement {

    public static let shared = Swifty360MotionManager()

    internal var observerItems = [NSUUID: Swifty360MotionManagerObserverItem]()
    internal let motionManager = CMMotionManager()
    internal static let preferredUpdateInterval = TimeInterval(1.0 / 60.0)

    private init() {
        motionManager.deviceMotionUpdateInterval = Swifty360MotionManager.preferredUpdateInterval
    }

    public var deviceMotionAvailable: Bool {
        return motionManager.isDeviceMotionAvailable
    }

    public var deviceMotionActive: Bool {
        return motionManager.isDeviceMotionActive
    }

    public var deviceMotion: CMDeviceMotion? {
        return motionManager.deviceMotion
    }

    public func startUpdating(preferredUpdateInterval: TimeInterval) -> NSUUID {
        assert(OperationQueue.current == OperationQueue.main, "Swifty360MotionManager should be used on main queue")
        let previousCount = observerItems.count
        let observerItem = Swifty360MotionManagerObserverItem(withPreferredUpdateInterval: preferredUpdateInterval)
        observerItems[observerItem.token] = observerItem
        motionManager.deviceMotionUpdateInterval = resolvedUpdateInterval()
        if observerItems.count > 0 && previousCount == 0 {
            motionManager.startDeviceMotionUpdates()
        }
        return observerItem.token
    }

    public func stopUpdating(token: NSUUID) {
        assert(OperationQueue.current == OperationQueue.main, "Swifty360MotionManager should be used on main queue")
        let previousCount = observerItems.count
        observerItems.removeValue(forKey: token)
        motionManager.deviceMotionUpdateInterval = resolvedUpdateInterval()
        if observerItems.count > 0 && previousCount == 0 {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    internal func numberOfObservers() -> Int {
        return observerItems.count
    }

    internal func resolvedUpdateInterval() -> TimeInterval {
        let observerItemValues = observerItems.values
        if observerItemValues.isEmpty {
            return Swifty360MotionManager.preferredUpdateInterval
        }
        let item = observerItemValues.min { $0.preferredUpdateInterval > $1.preferredUpdateInterval }
        if let item = item {
            return item.preferredUpdateInterval
        }
        return Swifty360MotionManager.preferredUpdateInterval
    }

}
