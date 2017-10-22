//
//  Swifty360CameraController.swift
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

public protocol Swifty360CameraControllerDelegate: class {
    func cameraController(controller: Swifty360CameraController, cameraMovedViewMethod: Swifty360UserInteractionMethod)
}

@inline(__always) func distance(a: CGPoint, b: CGPoint) -> CGFloat {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
}

@inline(__always) func subtractPoints(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: b.x - a.x, y: b.y - a.y)
}

typealias Swifty360CompassAngleUpdateBlock = (_ compassAngle: Float) -> (Void)

open class Swifty360CameraController: NSObject, UIGestureRecognizerDelegate {

    // public variables
    open weak var delegate: Swifty360CameraControllerDelegate?
    open var compassAngleUpdateBlock: Swifty360CompassAngleUpdateBlock?
    open var panRecognizer: Swifty360CameraPanGestureRecognizer!
    // Stored property
    private var deviceMotionPanningAxes: Swifty360PanningAxis!
    // Computed Property
    open var allowedDeviceMotionPanningAxes: Swifty360PanningAxis! {
        set {
            if deviceMotionPanningAxes != newValue {
                deviceMotionPanningAxes = newValue
                let result = Swifty360UpdatedPositionAndAnglesForAllowedAxes(position: self.currentPosition,
                                                                             allowedPanningAxes: deviceMotionPanningAxes)
                currentPosition = result.position
                pointOfView.eulerAngles = result.eulerAngles
            }
        }
        get {
            return deviceMotionPanningAxes
        }
    }
    // Stored property
    private var panGesturePanningAxes: Swifty360PanningAxis!
    // Computed Property
    open var allowedPanGesturePanningAxes: Swifty360PanningAxis! {
        set {
            if panGesturePanningAxes != newValue {
                panGesturePanningAxes = newValue
                let result = Swifty360UpdatedPositionAndAnglesForAllowedAxes(position: self.currentPosition,
                                                                             allowedPanningAxes: panGesturePanningAxes)
                currentPosition = result.position
                pointOfView.eulerAngles = result.eulerAngles
            }

        }
        get {
            return panGesturePanningAxes
        }
    }

    // private variables
    internal var view: SCNView!
    internal var motionManager: Swifty360MotionManagement!
    internal var motionUpdateToken: UUID?
    internal var pointOfView: SCNNode!
    internal var rotateStart: CGPoint!
    internal var rotateCurrent: CGPoint!
    internal var rotateDelta: CGPoint!
    internal var currentPosition: CGPoint!
    internal var isAnimatingReorientation: Bool!
    internal var hasReportedInitialCameraMovement: Bool!
    internal static let minimalRotationDistanceToReport = CGFloat(0.75)

    private override init() { }

    init(withView view: SCNView, motionManager: Swifty360MotionManagement) {
        super.init()

        assert(view.pointOfView != nil, "NYT360CameraController must be initialized with a view with a non-nil pointOfView node.")
        assert(view.pointOfView?.camera != nil, "NYT360CameraController must be initialized with a view with a non-nil camera node for view.pointOfView.")

        pointOfView = view.pointOfView
        self.view = view
        currentPosition = CGPoint(x: 3.14, y: 0.0)
        allowedDeviceMotionPanningAxes = .all
        allowedPanGesturePanningAxes = .all

        panRecognizer = Swifty360CameraPanGestureRecognizer(target: self, action: #selector(Swifty360CameraController.handlePan(recognizer:)))
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)

        self.motionManager = motionManager
        hasReportedInitialCameraMovement = false
    }

    func startMotionUpdates() {
        let preferredMotionUpdateInterval = TimeInterval(1.0 / 60.0)
        motionUpdateToken = motionManager.startUpdating(preferredUpdateInterval: preferredMotionUpdateInterval)
    }

    func stopMotionUpdates() {
        guard let motionUpdateToken = self.motionUpdateToken else {
            return
        }
        motionManager.stopUpdating(token: motionUpdateToken)
        self.motionUpdateToken = nil
    }

    func compassAngle() -> Float {
        return Swifty360CompassAngleForEulerAngles(eulerAngles: pointOfView.eulerAngles)
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if self.isAnimatingReorientation {
            return
        }

        let point = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            rotateStart = point
        case .changed:
            rotateCurrent = point
            rotateDelta = subtractPoints(a: self.rotateStart, b: self.rotateCurrent)
            rotateStart = rotateCurrent
            let result = Swifty360PanGestureChangeCalculation(position: currentPosition,
                                                              rotateDelta: rotateDelta,
                                                              viewSize: view.bounds.size,
                                                              allowedPanningAxes: allowedPanGesturePanningAxes)
            currentPosition = result.position
            pointOfView.eulerAngles = result.eulerAngles
            compassAngleUpdateBlock?(compassAngle())
            reportInitialCameraMovementIfNeeded(withMethod: .touch)
        default:
            break
        }
    }

    func updateCameraAngleForCurrentDeviceMotion() {
        if isAnimatingReorientation {
            return
        }

        guard let rotationRate = motionManager.deviceMotion?.rotationRate else {
            return
        }
        let orientation =  UIApplication.shared.statusBarOrientation
        let result = Swifty360DeviceMotionCalculation(position: currentPosition,
                                                      rotationRate: rotationRate,
                                                      orientation: orientation,
                                                      allowedPanningAxes: allowedDeviceMotionPanningAxes,
                                                      noiseThreshold: Double(Swifty360EulerAngleCalculationNoiseThresholdDefault))
        currentPosition = result.position
        pointOfView.eulerAngles = result.eulerAngles
        compassAngleUpdateBlock?(compassAngle())

        if distance(a: CGPoint.zero, b: currentPosition) > Swifty360CameraController.minimalRotationDistanceToReport {
            reportInitialCameraMovementIfNeeded(withMethod: .gyroscope)
        }
    }

    func updateCameraFOV(withViewSize viewSize: CGSize) {
        pointOfView.camera?.yFov = Swifty360OptimalYFovForViewSize(viewSize: viewSize).getDouble()
    }

    func reorientVerticalCameraAngleToHorizon(animated: Bool) {
        if animated {
            isAnimatingReorientation = true
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CATransaction.animationDuration()
        }

        currentPosition.y = 0
        pointOfView.eulerAngles.x = 0

        if animated {
            SCNTransaction.completionBlock = {
                SCNTransaction.animationDuration = 0
                self.isAnimatingReorientation = false
                SCNTransaction.commit()
            }
        }
    }

    func reportInitialCameraMovementIfNeeded(withMethod method: Swifty360UserInteractionMethod) {
        if !hasReportedInitialCameraMovement {
            hasReportedInitialCameraMovement = true
            delegate?.cameraController(controller: self, cameraMovedViewMethod: method)
        }
    }

}
