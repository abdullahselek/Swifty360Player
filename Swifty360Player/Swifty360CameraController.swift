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

protocol Swifty360CameraControllerDelegate: class {
    func cameraController(controller: Swifty360CameraController, cameraMovedViewMethod: Swifty360UserInteractionMethod)
}

typealias Swifty360CompassAngleUpdateBlock = (_ compassAngle: Float) -> (Void)

open class Swifty360CameraController: NSObject, UIGestureRecognizerDelegate {

    // public variables
    weak var delegate: Swifty360CameraControllerDelegate?
    var compassAngle: Float!
    var compassAngleUpdateBlock: Swifty360CompassAngleUpdateBlock?
    var panRecognizer: Swifty360CameraPanGestureRecognizer!
    var allowedDeviceMotionPanningAxes: Swifty360PanningAxis!
    var allowedPanGesturePanningAxes: Swifty360PanningAxis!

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

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {

    }

}
