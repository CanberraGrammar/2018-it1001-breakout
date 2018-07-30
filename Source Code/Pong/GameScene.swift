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
    let BottomCategory: UInt32 = 0x1 << 2
    
    var bottomPaddle: SKSpriteNode?
    var fingerOnBottomPaddle: Bool = false
    
    var bottomScoreLabel: SKLabelNode?
    
    var bottomScoreCount: Int = 0
    
    var ball: SKSpriteNode?
    
    var gameRunning: Bool = false
    
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
        ball!.physicsBody!.contactTestBitMask = BottomCategory
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        let bottomLeftPoint = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        let bottomRightPoint = CGPoint(x: size.width / 2, y: -(size.height / 2))
        
        let bottomNode = SKNode()
        bottomNode.physicsBody = SKPhysicsBody(edgeFrom: bottomLeftPoint, to: bottomRightPoint)
        bottomNode.physicsBody!.categoryBitMask = BottomCategory
        addChild(bottomNode)
        
        let numberOfBricks = 6
        let gapBetweenBricks = 10
        let totalGapsBetweenBricks = gapBetweenBricks * (numberOfBricks - 1)
        let brickWidth = (frame.size.width - CGFloat(totalGapsBetweenBricks)) / CGFloat(numberOfBricks)
        
        var yCoord = (frame.size.height / 2) - 100
        
        let colorArray: [UIColor] = [.blue, .red, .yellow, .green, .purple, .orange, .brown, .magenta]
        
        for _ in 0..<4 {
            
            for i in 0..<numberOfBricks {
                
                // let xCoordinate = (CGFloat(i) * brickWidth) - (frame.size.width / 2) + (brickWidth / 2)
                
                let gapOffset = CGFloat(i * gapBetweenBricks)
                let anchorCompenstation = (frame.size.width / 2)
                let brickWidthCompenstation = (brickWidth / 2)
                let xCoordinate = (CGFloat(i) * brickWidth) - anchorCompenstation + brickWidthCompenstation + gapOffset
                
                let randomNumber = Int(arc4random_uniform(UInt32(colorArray.count)))
                
                let brickNode = SKSpriteNode(color: colorArray[randomNumber], size: CGSize(width: brickWidth, height: 25))
                brickNode.position = CGPoint(x: xCoordinate, y: yCoord)
                
                addChild(brickNode)
                
            }
            
            yCoord -= 50
            
        }
        
        
        
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
        
        // Reset gameRunning to false
        gameRunning = false
        
    }
    
    func gameOver() {
        
        // Pause the game
        view!.isPaused = true
        
        // Show an alert
        let gameOverAlert = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        let gameOverAction = UIAlertAction(title: "Okay", style: .default) { (theAlertAction) in
            
            self.resetGame()
            
        }
        
        gameOverAlert.addAction(gameOverAction)
        
        self.view!.window!.rootViewController!.present(gameOverAlert, animated: true, completion: nil)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if ((contact.bodyA.categoryBitMask == BottomCategory) || (contact.bodyB.categoryBitMask == BottomCategory)) {
            
            print("Bottom collision")
            
            gameOver()
            
        }
        
    }
    
}

























