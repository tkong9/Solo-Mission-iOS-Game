//
//  GameScene.swift
//  Solo Mission
//
//  Created by TAEWON KONG on 9/13/19.
//  Copyright © 2019 TAEWON KONG. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore: Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let player = SKSpriteNode(imageNamed: "playerShip")
    var levelNumber = 0
    var gameArea: CGRect
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    let amountToMovePerSecond: CGFloat = 600.0
    
    struct PhysicsCategoris {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 // 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
    
    enum gameState {
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState: gameState = gameState.preGame
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        
        let playableWidth: CGFloat = size.height / maxAspectRatio
        
        let margin = (size.width - playableWidth) / 2.0
        
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
//            background.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
            background.position = CGPoint(x: self.size.width / 2.0, y: self.size.height * CGFloat(1))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        player.setScale(2)
        player.position = CGPoint(x: self.size.width / 2 , y: 0 - self.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategoris.Player
        player.physicsBody?.collisionBitMask = PhysicsCategoris.None
        player.physicsBody?.contactTestBitMask = PhysicsCategoris.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text =  "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)

        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(2)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategoris.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategoris.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategoris.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy() {
    
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(2)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategoris.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategoris.None
        enemy.physicsBody?.contactTestBitMask = PhysicsCategoris.Bullet | PhysicsCategoris.Player
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALiveAction = SKAction.run(loseALife)
        
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALiveAction])
        
        if currentGameState == gameState.inGame {
            enemy.run(enemySequence)
        }
        let dx: CGFloat = endPoint.x - endPoint.y
        let dy: CGFloat = endPoint.y - endPoint.y
        let amountToRotate = atan2(dx, dy)
        enemy.zRotation = amountToRotate
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame {
            startGame()
        } else if currentGameState == gameState.inGame {
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame {
                player.position.x += amountDragged
            }

            if player.position.x > gameArea.maxX - player.size.width / 2.0 {
                player.position.x = gameArea.maxX - player.size.width / 2.0
            } else if player.position.x < gameArea.minX + player.size.width / 2.0 {
                player.position.x = gameArea.minX + player.size.width / 2.0
            }
        }
    }
    
    func startNewLevel() {
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        
        switch levelNumber {
        case 1:
            levelDuration = 1.2
        case 2:
            levelDuration = 1
        case 3:
            levelDuration = 0.8
        case 4:
            levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }

        if body1.categoryBitMask == PhysicsCategoris.Player && body2.categoryBitMask == PhysicsCategoris.Enemy {
            
            if let body1Position = body1.node?.position {
                spawnExplosion(spawnPosition: body1Position)
            }
            
            if let body2Position = body2.node?.position {
                spawnExplosion(spawnPosition: body2Position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }

        if body1.categoryBitMask == PhysicsCategoris.Bullet && body2.categoryBitMask == PhysicsCategoris.Enemy {
            addScore()
            if body2.node != nil {
                if body2.node!.position.y > self.size.height {
                    return
                }
                else{
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()

        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 2, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 20 || gameScore == 30 {
            startNewLevel()
        }
    }
    
    func loseALife() {
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
    }
    
    func runGameOver() {
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") { (bullet, stop) in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy") { (enemy, stop) in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSquence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSquence)
    }
    
    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background") { (background, stop) in
            if self.currentGameState == gameState.inGame {
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
    
}
