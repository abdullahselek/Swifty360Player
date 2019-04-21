[![Build Status](https://travis-ci.org/abdullahselek/Swifty360Player.svg?branch=master)](https://travis-ci.org/abdullahselek/Swifty360Player)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Swifty360Player.svg)](https://cocoapods.org/pods/Swifty360Player)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License](https://img.shields.io/dub/l/vibe-d.svg)

# ![Swifty360Player](https://github.com/abdullahselek/Swifty360Player/blob/master/Resources/Swifty360Player.png) Swifty360Player

iOS 360-degree video player streaming from an AVPlayer.

## Demo

![Swifty360Player Demo](https://github.com/abdullahselek/Swifty360Player/blob/master/Resources/demo.gif)

## Requirements

| Swifty360Player Version | Minimum iOS Target  | Swift Version |
|:--------------------:|:---------------------------:|:---------------------------:|
| 0.2.3 | 11.0 | 5.0 |
| 0.2.2 | 10.0 | 4.2 |
| 0.2.1 | 10.0 | 4.1 |
| 0.2 | 10.0 | 4.0 |

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:

``` 
$ gem install cocoapods
```

To integrate Swifty360Player into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Swifty360Player', '0.2.3'
end
```

Then, run the following command:

```
$ pod install
```

## Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```

To integrate Swifty360Player into your Xcode project using Carthage, specify it in your Cartfile:

```
github "abdullahselek/Swifty360Player" ~> 0.2.3
```

## Swift Package Manager

```
// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Your project name",
    dependencies: [
        .package(url: "https://github.com/abdullahselek/Swifty360Player.git", from: "0.2.3"),
    ],
    targets: [
        .target(
            name: "Your project name",
            dependencies: ["Swifty360Player"]),
    ]
)
```

Run `swift package resolve`

Run carthage update to build the framework and drag the built Swifty360Player.framework into your Xcode project.

## Example Usage

You just need an `AVPlayer` instance created with a valid video url and a `Swifty360MotionManager` instance. You can use these code snippets in a `UIViewController` instance.

Video url can be either local or remote.

```
let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "google-help-vr", ofType: "mp4")!)
let player = AVPlayer(url: videoURL)

let motionManager = Swifty360MotionManager.shared
swifty360ViewController = Swifty360ViewController(withAVPlayer: player, motionManager: motionManager)

addChildViewController(swifty360ViewController)
view.addSubview(swifty360ViewController.view)
swifty360ViewController.didMove(toParentViewController: self)

player.play()

let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reorientVerticalCameraAngle))
view.addGestureRecognizer(tapGestureRecognizer)
```

Tap Gesture Handler

```
@objc func reorientVerticalCameraAngle() {
    swifty360ViewController.reorientVerticalCameraAngleToHorizon(animated: true)
}
```

Using storyboard and `Swifty360ViewController` as parent class

```
guard let swifty360ViewController = self.storyboard?.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController else {
    return
}
let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "google-help-vr", ofType: "mp4")!)
let player = AVPlayer(url: videoURL)
let motionManager = Swifty360MotionManager.shared
swifty360ViewController.player = player
swifty360ViewController.motionManager = motionManager
self.present(swifty360ViewController, animated: true, completion: nil)
```

```
import UIKit
import Swifty360Player

class TestViewController: Swifty360ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        player.play()
    }

}
```

Example use of `Swifty360View` with using code commands

```
let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "google-help-vr", ofType: "mp4")!)
let player = AVPlayer(url: videoURL)

let motionManager = Swifty360MotionManager.shared

let swifty360View = Swifty360View(withFrame: view.bounds,
                                  player: player,
                                  motionManager: motionManager)
swifty360View.setup(player: player, motionManager: motionManager)
view.addSubview(swifty360View)

player.play()
```

Using `Swifty360View` with Storyboard

- Add a `UIView` to your viewcontroller and change it's class as `Swifty360View`
- Connect via IBOutlets

and 

```
let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "google-help-vr", ofType: "mp4")!)
let player = AVPlayer(url: videoURL)

let motionManager = Swifty360MotionManager.shared

swifty360View.setup(player: player, motionManager: motionManager)

player.play()
```

Tap gesture recognizers for `Swifty360View`, create one recognizer for your viewcontroller's view

```
let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reorientVerticalCameraAngle))
view.addGestureRecognizer(tapGestureRecognizer)
```

and selector function

```
@objc func reorientVerticalCameraAngle() {
    swifty360View.reorientVerticalCameraAngleToHorizon(animated: true)
}
```

## License

Swifty360Player is released under the MIT license. See LICENSE for details.
