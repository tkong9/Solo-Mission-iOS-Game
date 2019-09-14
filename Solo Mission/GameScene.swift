//
//  GameScene.swift
//  Solo Mission
//
//  Created by TAEWON KONG on 9/13/19.
//  Copyright © 2019 TAEWON KONG. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    var gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        
        let playableWidth: CGFloat = size.height / maxAspectRatio
        
        let margin = (size.width - playableWidth) / 2.0
        
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width / 2 , y: self.size.width * 0.2)
        player.zPosition = 2
        self.addChild(player)
        
        startNewLevel()
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
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
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx: CGFloat = endPoint.x - endPoint.y
        let dy: CGFloat = endPoint.y - endPoint.y
        let amountToRotate = atan2(dx, dy)
        enemy.zRotation = amountToRotate
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            player.position.x += amountDragged
            
            if player.position.x > gameArea.maxX - player.size.width / 2.0 {
                player.position.x = gameArea.maxX - player.size.width / 2.0
            } else if player.position.x < gameArea.minX + player.size.width / 2.0 {
                player.position.x = gameArea.minX + player.size.width / 2.0
            }
        }
    }
    
    func startNewLevel() {
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
    }
}
