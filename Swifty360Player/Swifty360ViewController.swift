//
//  Swifty360ViewController.swift
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

public protocol Swifty360ViewControllerDelegate: class {
    func didUpdateCompassAngle(withViewController: Swifty360ViewController, compassAngle: Float)
    func userInitallyMovedCameraViaMethod(withViewController: Swifty360ViewController, method: Swifty360UserInteractionMethod)
}

open class Swifty360ViewController: UIViewController, Swifty360CameraControllerDelegate {

    open weak var delegate: Swifty360ViewControllerDelegate?
    open var player: AVPlayer!
    open var motionManager: Swifty360MotionManagement!
    open var compassAngle: Float!
    open var panRecognizer: Swifty360CameraPanGestureRecognizer!
    open var allowedDeviceMotionPanningAxes: Swifty360PanningAxis = .all
    open var allowedPanGesturePanningAxes: Swifty360PanningAxis = .all

    private var underlyingSceneSize: CGSize!
    private var sceneView: SCNView!
    private var playerScene: Swifty360PlayerScene!
    private var cameraController: Swifty360CameraController!

    public init(withAVPlayer player: AVPlayer, motionManager: Swifty360MotionManagement) {
        super.init(nibName: nil, bundle: nil)
        let screenBounds = UIScreen.main.bounds
        let initialSceneFrame = sceneBoundsForScreenBounds(screenBounds: screenBounds)
        underlyingSceneSize = initialSceneFrame.size
        sceneView = SCNView(frame: initialSceneFrame)
        playerScene = Swifty360PlayerScene(withAVPlayer: player, view: sceneView)
        cameraController = Swifty360CameraController(withView: sceneView, motionManager: motionManager)
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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func play() {
        playerScene.play()
    }

    open func pause() {
        playerScene.pause()
    }

    internal func sceneBoundsForScreenBounds(screenBounds: CGRect) -> CGRect {
        let maxValue = max(screenBounds.size.width, screenBounds.size.height)
        let minValue = min(screenBounds.size.width, screenBounds.size.height)
        return CGRect(x: 0.0, y: 0.0, width: maxValue, height: minValue)
    }

    public func cameraController(controller: Swifty360CameraController, cameraMovedViewMethod: Swifty360UserInteractionMethod) {

    }

    deinit {
        sceneView.delegate = nil
    }

}

extension Swifty360ViewController: SCNSceneRendererDelegate {

}
