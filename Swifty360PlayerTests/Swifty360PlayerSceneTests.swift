import AVFoundation
import SceneKit
import SpriteKit
import XCTest

@testable import Swifty360Player

final class Swifty360PlayerSceneTests: XCTestCase {

    func testPlayerSceneContainsOneVideoNode() {
        let player = AVPlayer()
        let view = SCNView(frame: .zero)
        let playerScene = Swifty360PlayerScene(withAVPlayer: player, view: view)
        let sphereNode = playerScene.rootNode.childNodes.first {
            $0.geometry?.firstMaterial?.diffuse.contents is SKScene
        }
        guard let spriteScene = sphereNode?.geometry?.firstMaterial?.diffuse.contents as? SKScene else {
            XCTFail("The video sphere should use its SpriteKit scene as the diffuse texture.")
            return
        }

        XCTAssertEqual(spriteScene.children.filter { $0 is SKVideoNode }.count, 1)
    }

}
