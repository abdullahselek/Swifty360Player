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

/**
 Expectations that must be fulfilled by an appliation-wide "wrapper" around
 CMMotionManager for Swifty360Player's use.

 Per Apple's documentation, it is recommended that an application will have no
 more than one `CMMotionManager`, otherwise performance could degrade.

 A host application is free to provide a custom class conforming to
 `Swifty360MotionManagement`. If your application does not use a CMMotionManager
 outside of Swifty360Player, I recommend that you use the shared instance of
 `Swifty360MotionManager`, a ready-made class that already conforms to
 `Swifty360MotionManagement`.
 */
public protocol Swifty360MotionManagement {

    /**
     Determines whether device motion hardware and APIs are available.
     */
    var deviceMotionAvailable: Bool { get }
    /**
     Determines whether the receiver is currently providing motion updates.
     */
    var deviceMotionActive: Bool { get }
    /**
     Returns the latest sample of device motion data, or nil if none is available.
     */
    var deviceMotion: CMDeviceMotion? { get }

    /**
     Begins updating device motion, if it hasn't begun already.

     - Parameter preferredUpdateInterval: The requested update interval. The actual
     interval used should resolve to the shortest requested interval among the
     active requests.

     - Returns: A token which the caller should use to balance this call with a
     call to `stopUpdating`.

     - Warning: Callers should balance a call to `startUpdating` with a call to
     `stopUpdating`, otherwise device motion will continue to be updated indefinitely.
     */
    func startUpdating(preferredUpdateInterval: TimeInterval) -> UUID
    /**
     Requests that device motion updates be stopped. If there are other active
     observers that still require device motion updates, motion updates will not be
     stopped.

     The device motion update interval may be raised or lowered after a call to
     `stopUpdating`, as the interval will resolve to the shortest interval among
     the active observers.

     - Parameter token: The token received from a call to `startUpdating`.

     - Warning: Callers should balance a call to `startUpdating` with a call to
     `stopUpdating`, otherwise device motion will continue to be updated indefinitely.
     */
    func stopUpdating(token: UUID)

}

/**
 A reference implementation of `Swifty360MotionManagement`. Your host application
 can provide another implementation if so desired.

 - SeeAlso: `Swifty360ViewController`.
 */
open class Swifty360MotionManager: Swifty360MotionManagement {

    /**
     The shared, app-wide `Swifty360MotionManager`.
     */
    public static let shared = Swifty360MotionManager()

    internal var observerItems = [UUID: Swifty360MotionManagerObserverItem]()
    internal let motionManager = CMMotionManager()
    internal static let preferredUpdateInterval = TimeInterval(1.0 / 60.0)

    // MARK: Init

    private init() {
        motionManager.deviceMotionUpdateInterval = Swifty360MotionManager.preferredUpdateInterval
    }

    // MARK: Swifty360MotionManagement

    public var deviceMotionAvailable: Bool {
        return motionManager.isDeviceMotionAvailable
    }

    public var deviceMotionActive: Bool {
        return motionManager.isDeviceMotionActive
    }

    public var deviceMotion: CMDeviceMotion? {
        return motionManager.deviceMotion
    }

    public func startUpdating(preferredUpdateInterval: TimeInterval) -> UUID {
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

    public func stopUpdating(token: UUID) {
        assert(OperationQueue.current == OperationQueue.main, "Swifty360MotionManager should be used on main queue")
        let previousCount = observerItems.count
        observerItems.removeValue(forKey: token)
        motionManager.deviceMotionUpdateInterval = resolvedUpdateInterval()
        if observerItems.count > 0 && previousCount == 0 {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    // MARK: Internal

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
