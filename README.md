[![Build Status](https://travis-ci.org/abdullahselek/Swifty360Player.svg?branch=master)](https://travis-ci.org/abdullahselek/Swifty360Player)
![License](https://img.shields.io/dub/l/vibe-d.svg)

# Swifty360Player

iOS 360-degree video player streaming from an AVPlayer.

## Demo

![Swifty360Player Demo](https://github.com/abdullahselek/Swifty360Player/blob/master/Demo/demo.gif)

## Requirements

| Swifty360Player Version | Minimum iOS Target  | Swift Version |
|:--------------------:|:---------------------------:|:---------------------------:|
| 0.1 | 10.0 | 4.0 |

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:

``` 
$ gem install cocoapods
```

To integrate Swifty360Player into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Swifty360Player', '0.1'
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
github "abdullahselek/Swifty360Player" ~> 0.1
```

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

## License

Swifty360Player is released under the MIT license. See LICENSE for details.
