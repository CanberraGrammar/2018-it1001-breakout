//
//  GameScene.swift
//  Pong
//
//  Created by MPP on 22/5/18.
//  Copyright © 2018 Matthew Purcell. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory: UInt32 = 0x1 << 0
    let BrickCategory: UInt32 = 0x1 << 1
    let BottomCategory: UInt32 = 0x1 << 2
    
    var bottomPaddle: SKSpriteNode?
    var fingerOnBottomPaddle: Bool = false
    
    var bottomScoreLabel: SKLabelNode?
    
    var bottomScoreCount: Int = 0
    
    var ball: SKSpriteNode?
    
    var gameRunning: Bool = false
    
    var totalBricks: Int = 0
    var totalTime: Int = 0
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
      
        bottomPaddle = childNode(withName: "bottomPaddle") as? SKSpriteNode
        bottomPaddle!.physicsBody = SKPhysicsBody(rectangleOf: bottomPaddle!.frame.size)
        bottomPaddle!.physicsBody!.isDynamic = false
        
        bottomScoreLabel = childNode(withName: "bottomScoreLabel") as? SKLabelNode
        
        ball = childNode(withName: "ball") as? SKSpriteNode
        ball!.physicsBody = SKPhysicsBody(rectangleOf: ball!.frame.size)
        ball!.physicsBody!.friction = 0
        ball!.physicsBody!.restitution = 1
        ball!.physicsBody!.linearDamping = 0
        ball!.physicsBody!.angularDamping = 0
        ball!.physicsBody!.allowsRotation = false
        ball!.physicsBody!.categoryBitMask = BallCategory
        ball!.physicsBody!.contactTestBitMask = BottomCategory | BrickCategory
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        let bottomLeftPoint = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        let bottomRightPoint = CGPoint(x: size.width / 2, y: -(size.height / 2))
        
        let bottomNode = SKNode()
        bottomNode.physicsBody = SKPhysicsBody(edgeFrom: bottomLeftPoint, to: bottomRightPoint)
        bottomNode.physicsBody!.categoryBitMask = BottomCategory
        addChild(bottomNode)
        
        
        generateBricks()
        
        
        
        /*
        let testNode = SKSpriteNode(color: UIColor.red, size: CGSize(width: 50, height: 50))
        testNode.position = CGPoint(x: 100, y: 200)
        addChild(testNode)
        */
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if touchedNode.name == "bottomPaddle" {
            fingerOnBottomPaddle = true
        }
        
        if gameRunning == false {
            
            // Generate a random number between 0 and 1 (inclusive!)
            let randomNumber = Int(arc4random_uniform(2))
            
            if randomNumber == 0 {
            
                ball!.physicsBody!.applyImpulse(CGVector(dx: 5, dy: 5))
            
            }
            
            else {
                
                ball!.physicsBody!.applyImpulse(CGVector(dx: -5, dy: -5))
            }

            gameRunning = true
            
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                self.totalTime += 1
                self.bottomScoreLabel!.text = String(self.totalTime)
            })
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let previousTouchLocation = touch.previousLocation(in: self)
        
        if fingerOnBottomPaddle == true && touchLocation.y < 0 {
        
            let paddleX = bottomPaddle!.position.x + (touchLocation.x - previousTouchLocation.x)
        
            if (paddleX - bottomPaddle!.size.width / 2) > -(self.size.width / 2) &&
                (paddleX + bottomPaddle!.size.width / 2) < (self.size.width / 2) {
            
                bottomPaddle!.position = CGPoint(x: paddleX, y: -560.0)
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if fingerOnBottomPaddle == true {
            
            fingerOnBottomPaddle = false
            
        }
        
    }
    
    func resetGame() {
        
        // Reset the position of the paddles
        bottomPaddle!.position.x = 0
        
        // Reset the ball
        
        // i. middle of the screen
        ball!.position.x = 0
        ball!.position.y = 0
        
        // ii. not moving
        ball!.physicsBody!.isDynamic = false
        ball!.physicsBody!.isDynamic = true
        
        // Unpause the game
        view!.isPaused = false
        
        // Reset timer
        totalTime = 0
        bottomScoreLabel!.text = "0"
        gameTimer = nil
        
        // Remove all bricks
        removeAllBricks()
        
        // Respawn bricks
        generateBricks()
        
        // Reset gameRunning to false
        gameRunning = false
        
    }
    
    func generateBricks() {
        
        let numberOfBricks = 6
        let numberOfRows = 4
        let gapBetweenBricks = 10
        let totalGapsBetweenBricks = gapBetweenBricks * (numberOfBricks - 1)
        let brickWidth = (frame.size.width - CGFloat(totalGapsBetweenBricks)) / CGFloat(numberOfBricks)
        
        totalBricks = numberOfBricks * numberOfRows
        
        var yCoord = (frame.size.height / 2) - 100
        
        let colorArray: [UIColor] = [.blue, .red, .yellow, .green, .purple, .orange, .brown, .magenta]
        
        for _ in 0..<numberOfRows {
            
            for i in 0..<numberOfBricks {
                
                // let xCoordinate = (CGFloat(i) * brickWidth) - (frame.size.width / 2) + (brickWidth / 2)
                
                let gapOffset = CGFloat(i * gapBetweenBricks)
                let anchorCompenstation = (frame.size.width / 2)
                let brickWidthCompenstation = (brickWidth / 2)
                let xCoordinate = (CGFloat(i) * brickWidth) - anchorCompenstation + brickWidthCompenstation + gapOffset
                
                let randomNumber = Int(arc4random_uniform(UInt32(colorArray.count)))
                
                let brickNode = SKSpriteNode(color: colorArray[randomNumber], size: CGSize(width: brickWidth, height: 25))
                brickNode.physicsBody = SKPhysicsBody(rectangleOf: brickNode.size)
                brickNode.physicsBody!.isDynamic = false
                brickNode.physicsBody!.categoryBitMask = BrickCategory
                brickNode.name = "brick"
                brickNode.position = CGPoint(x: xCoordinate, y: yCoord)
                
                addChild(brickNode)
                
            }
            
            yCoord -= 50
            
        }
        
    }
    
    func removeAllBricks() {
        
        enumerateChildNodes(withName: "brick") { (node, _) in
            node.removeFromParent()
        }
        
        /*let allNodes = children
        
        for node in allNodes {
            
            if node.name == "brick" {
                node.removeFromParent()
            }
            
        }*/
        
    }
    
    func gameOver() {
        
        // Pause the game
        view!.isPaused = true
        gameTimer!.invalidate()
        
        // Show an alert
        let gameOverAlert = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        let gameOverAction = UIAlertAction(title: "Okay", style: .default) { (theAlertAction) in
            
            self.resetGame()
            
        }
        
        gameOverAlert.addAction(gameOverAction)
        
        self.view!.window!.rootViewController!.present(gameOverAlert, animated: true, completion: nil)
        
    }
    
    func checkForWin() {
        
        if totalBricks == 0 {
            
            view!.isPaused = true
            gameTimer!.invalidate()
            
            let winAlert = UIAlertController(title: "You Won!", message: nil, preferredStyle: .alert)
            let winAction = UIAlertAction(title: "Okay", style: .default) { (theAlertAction) in
                
                self.resetGame()
                
            }
            
            winAlert.addAction(winAction)
            self.view!.window!.rootViewController!.present(winAlert, animated: true, completion: nil)
            
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if ((contact.bodyA.categoryBitMask == BottomCategory) || (contact.bodyB.categoryBitMask == BottomCategory)) {
            
            print("Bottom collision")
            
            gameOver()
            
        }
        
        else if contact.bodyA.categoryBitMask == BrickCategory {
            
            let emitter = SKEmitterNode(fileNamed: "BrickExplode")
            emitter!.position = contact.bodyA.node!.position
            addChild(emitter!)
            contact.bodyA.node!.removeFromParent()
            
            let emitterDelayAction = SKAction.wait(forDuration: 2.0)
            let emitterFadeAction = SKAction.fadeOut(withDuration: 1.0)
            let emitterRemoveAction = SKAction.removeFromParent()
            
            let emitterDisapperanceActions = [emitterDelayAction, emitterFadeAction, emitterRemoveAction]
            
            emitter!.run(SKAction.sequence(emitterDisapperanceActions))
            
            totalBricks -= 1
            
            checkForWin()
            
        }
        
        else if contact.bodyB.categoryBitMask == BrickCategory {
            
            let emitter = SKEmitterNode(fileNamed: "BrickExplode")
            emitter!.position = contact.bodyB.node!.position
            addChild(emitter!)
            contact.bodyB.node!.removeFromParent()
            
            let emitterDelayAction = SKAction.wait(forDuration: 2.0)
            let emitterFadeAction = SKAction.fadeOut(withDuration: 1.0)
            let emitterRemoveAction = SKAction.removeFromParent()
            
            let emitterDisapperanceActions = [emitterDelayAction, emitterFadeAction, emitterRemoveAction]
            
            emitter!.run(SKAction.sequence(emitterDisapperanceActions))
            
            totalBricks -= 1
            
            checkForWin()
            
        }
        
    }
    
}

























