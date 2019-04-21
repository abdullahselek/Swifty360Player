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

@inline(__always) func Swifty360ViewControllerSceneFrameForContainingBounds(containingBounds: CGRect, underlyingSceneSize: CGSize) -> CGRect {
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

@inline(__always) func Swifty360ViewControllerSceneBoundsForScreenBounds(screenBounds: CGRect) -> CGRect {
    let maxValue = max(screenBounds.size.width, screenBounds.size.height)
    let minValue = min(screenBounds.size.width, screenBounds.size.height)
    return CGRect(x: 0.0, y: 0.0, width: maxValue, height: minValue)
}

open class Swifty360ViewController: UIViewController, Swifty360CameraControllerDelegate {

    open weak var delegate: Swifty360ViewControllerDelegate?
    open var player: AVPlayer!
    open var motionManager: Swifty360MotionManagement?
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
    private var playerView = UIView()

    public init(withAVPlayer player: AVPlayer, motionManager: Swifty360MotionManagement?) {
        super.init(nibName: nil, bundle: nil)
        self.player = player
        self.motionManager = motionManager
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate func addPlayerViewConstraints() {
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
            ])
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: playerView.bottomAnchor, multiplier: 1.0)
            ])
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        assert(player != nil, "Swifty360ViewController should have an AVPlayer instance")

        setup(player: player, motionManager: motionManager)

        view.backgroundColor = UIColor.black
        view.isOpaque = true
        view.clipsToBounds = true

        playerView.isUserInteractionEnabled = true
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)

        addPlayerViewConstraints()

        sceneView.backgroundColor = UIColor.black
        sceneView.isOpaque = true
        sceneView.delegate = self
        playerView.addSubview(sceneView)

        sceneView.isPlaying = true

        cameraController.updateCameraFOV(withViewSize: view.bounds.size)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = Swifty360ViewControllerSceneFrameForContainingBounds(containingBounds: view.bounds,
                                                                               underlyingSceneSize: underlyingSceneSize)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraController.startMotionUpdates()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraController.stopMotionUpdates()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            SCNTransaction.animationDuration = coordinator.transitionDuration
            self.cameraController.updateCameraFOV(withViewSize: size)
        }) { context in
            if !context.isCancelled {
                SCNTransaction.animationDuration = 0
            }
        }
    }

    open func play() {
        playerScene.play()
    }

    open func pause() {
        playerScene.pause()
    }

    open func reorientVerticalCameraAngleToHorizon(animated: Bool) {
        cameraController.reorientVerticalCameraAngleToHorizon(animated: animated)
    }

    internal func sceneBoundsForScreenBounds(screenBounds: CGRect) -> CGRect {
        let maxValue = max(screenBounds.size.width, screenBounds.size.height)
        let minValue = min(screenBounds.size.width, screenBounds.size.height)
        return CGRect(x: 0.0, y: 0.0, width: maxValue, height: minValue)
    }

    internal func setup(player: AVPlayer, motionManager: Swifty360MotionManagement?) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = playerView.layer.bounds
        playerView.layer.addSublayer(playerLayer)

        let screenBounds = playerView.bounds
        let initialSceneFrame = sceneBoundsForScreenBounds(screenBounds: screenBounds)
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

    public func userInitallyMovedCamera(withCameraController controller: Swifty360CameraController, cameraMovedViewMethod: Swifty360UserInteractionMethod) {
        delegate?.userInitallyMovedCameraViaMethod(withViewController: self, method: cameraMovedViewMethod)
    }

    deinit {
        sceneView.delegate = nil
    }

}

extension Swifty360ViewController: SCNSceneRendererDelegate {

    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.cameraController.updateCameraAngleForCurrentDeviceMotion()
        }
    }

}
