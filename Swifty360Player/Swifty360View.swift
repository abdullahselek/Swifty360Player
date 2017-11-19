//
//  Swifty360View.swift
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

import UIKit
import SceneKit
import AVFoundation

public protocol Swifty360ViewDelegate: class {
    func didUpdateCompassAngle(withViewController: Swifty360View, compassAngle: Float)
    func userInitallyMovedCameraViaMethod(withView: Swifty360View, method: Swifty360UserInteractionMethod)
}

@inline(__always) func Swifty360ViewSceneFrameForContainingBounds(containingBounds: CGRect, underlyingSceneSize: CGSize) -> CGRect {
    if underlyingSceneSize.equalTo(CGSize.zero) {
        return containingBounds
    }

    let containingSize = containingBounds.size
    let heightRatio = containingSize.height / underlyingSceneSize.height
    let widthRatio = containingSize.width / underlyingSceneSize.width
    var targetSize: CGSize!
    if heightRatio > widthRatio {
        targetSize = CGSize(width: underlyingSceneSize.width * heightRatio, height: underlyingSceneSize.height * heightRatio)
    } else {
        targetSize = CGSize(width: underlyingSceneSize.width * widthRatio, height: underlyingSceneSize.height * widthRatio)
    }

    var targetFrame = CGRect.zero
    targetFrame.size = targetSize
    targetFrame.origin.x = (containingBounds.size.width - targetSize.width) / 2.0
    targetFrame.origin.y = (containingBounds.size.height - targetSize.height) / 2.0

    return targetFrame
}

@inline(__always) func Swifty360ViewSceneBoundsForScreenBounds(screenBounds: CGRect) -> CGRect {
    let maxValue = max(screenBounds.size.width, screenBounds.size.height)
    let minValue = min(screenBounds.size.width, screenBounds.size.height)
    return CGRect(x: 0.0, y: 0.0, width: maxValue, height: minValue)
}

open class Swifty360View: UIView {

    open weak var delegate: Swifty360ViewDelegate?
    open var player: AVPlayer!
    open var motionManager: Swifty360MotionManagement!
    open var compassAngle: Float! {
        return cameraController.compassAngle()
    }
    open var panRecognizer: Swifty360CameraPanGestureRecognizer! {
        return cameraController.panRecognizer
    }
    open var allowedDeviceMotionPanningAxes: Swifty360PanningAxis {
        set {
            cameraController.allowedDeviceMotionPanningAxes = newValue
        }
        get {
            return cameraController.allowedDeviceMotionPanningAxes
        }
    }
    open var allowedPanGesturePanningAxes: Swifty360PanningAxis {
        set {
            cameraController.allowedPanGesturePanningAxes = newValue
        }
        get {
            return cameraController.allowedPanGesturePanningAxes
        }
    }

    private var underlyingSceneSize: CGSize!
    private var sceneView: SCNView!
    private var playerScene: Swifty360PlayerScene!
    private var cameraController: Swifty360CameraController!

    public init(withFrame frame: CGRect,
                player: AVPlayer,
                motionManager: Swifty360MotionManagement) {
        super.init(frame: frame)
        self.player = player
        self.motionManager = motionManager
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        assert(player != nil, "Swifty360View should have an AVPlayer instance")
        assert(motionManager != nil, "Swifty360View should have an Swifty360MotionManager instance")

        setup(player: player, motionManager: motionManager)
    }

    internal func sceneBoundsForScreenBounds(screenBounds: CGRect) -> CGRect {
        let maxValue = max(screenBounds.size.width, screenBounds.size.height)
        let minValue = min(screenBounds.size.width, screenBounds.size.height)
        return CGRect(x: 0.0, y: 0.0, width: maxValue, height: minValue)
    }

    internal func setup(player: AVPlayer, motionManager: Swifty360MotionManagement) {
        let initialSceneFrame = sceneBoundsForScreenBounds(screenBounds: bounds)
        underlyingSceneSize = initialSceneFrame.size
        sceneView = SCNView(frame: initialSceneFrame)
        playerScene = Swifty360PlayerScene(withAVPlayer: player, view: sceneView)
        self.motionManager = motionManager
        cameraController = Swifty360CameraController(withView: sceneView, motionManager: self.motionManager)
        cameraController.delegate = self
        weak var weakSelf = self
        cameraController.compassAngleUpdateBlock = { compassAngle in
            guard let strongSelf = weakSelf else {
                return
            }
            strongSelf.delegate?.didUpdateCompassAngle(withViewController: strongSelf,
                                                       compassAngle: strongSelf.compassAngle)
        }
    }

}

extension Swifty360View: Swifty360CameraControllerDelegate {

    public func userInitallyMovedCamera(withCameraController controller: Swifty360CameraController,
                                        cameraMovedViewMethod: Swifty360UserInteractionMethod) {
        delegate?.userInitallyMovedCameraViaMethod(withView: self, method: cameraMovedViewMethod)
    }

}
