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

open class Swifty360View: UIView {

    open weak var delegate: Swifty360ViewDelegate?
    open var player: AVPlayer!
    open var motionManager: Swifty360MotionManagement!

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
    }

}
