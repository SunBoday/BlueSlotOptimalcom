//
//  BloonGameVC.swift
//  BlueSlotOptimalcom
//
//  Created by Hiren on 18/09/24.
//

import UIKit
import SpriteKit

class BloonGameVC: UIViewController {
    
    @IBOutlet weak var viewGame: UIView!
    
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblLife: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var score: Int = 0
    var lives: Int = 3
    var gameTimer: Timer?
    var timeRemaining: Int = 30
    var isGamePaused: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameScene()
        startTimer()
    }
    
    func setupGameScene() {
        let skView = SKView(frame: viewGame.bounds)
        viewGame.addSubview(skView)
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        
        skView.backgroundColor = .clear
        scene.backgroundColor = .clear
        
        scene.setLife = {
            self.loseLife()
        }
        
        scene.setScore = {
            self.updateScore(by: 1)
        }
        
    }
    
    func updateScore(by points: Int) {
        score += points
        lblScore.text = "Score: \(score)"
    }
    
    @IBAction func clickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func loseLife() {
        lives -= 1
        lblLife.text = "Lives: \(lives)"
        
        if lives <= 0 {
            pauseGame()
        }
    }
    
    func startTimer() {
        lblTime.text = "Time: \(timeRemaining)"
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if !isGamePaused {
            timeRemaining -= 1
            lblTime.text = "Time: \(timeRemaining)"
            
            if timeRemaining <= 0 {
                pauseGame()
            }
        }
    }
    
    func pauseGame() {
        isGamePaused = true
        gameTimer?.invalidate()
        
        if let scene = (viewGame.subviews.first as? SKView)?.scene as? GameScene {
            scene.pauseGame()
        }
        
        let alert = UIAlertController(title: "Time's Up!", message: "Your score: \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true)
    }
    
    func resetGame() {
        score = 0
        lives = 3
        timeRemaining = 30
        lblScore.text = "Score: \(score)"
        lblLife.text = "Lives: \(lives)"
        lblTime.text = "Time: \(timeRemaining)"
        isGamePaused = false
        startTimer()
        
        if let scene = (viewGame.subviews.first as? SKView)?.scene as? GameScene {
            scene.resetScene()
        }
    }
    
}


class GameScene: SKScene {
    
    var isGamePaused: Bool = false
    
    var setScore: (()->Void)?
    var setLife: (()->Void)?
    
    override func didMove(to view: SKView) {
        backgroundColor = .cyan
        spawnBalloon()
    }
    
    func spawnBalloon() {
        let balloon = SKSpriteNode(imageNamed: "balloon")
        balloon.size = CGSize(width: 60, height: 80)
        balloon.position = CGPoint(x: CGFloat.random(in: 50...(size.width - 50)), y: -50)
        balloon.name = "balloon"
        addChild(balloon)
        
        let moveAction = SKAction.move(to: CGPoint(x: balloon.position.x, y: size.height + 50), duration: TimeInterval(CGFloat.random(in: 3...5)))
        
        let checkTop = SKAction.run {
            if balloon.position.y >= self.size.height {
                self.setLife?()
                balloon.removeFromParent()
            }
        }
        
        let sequence = SKAction.sequence([moveAction, checkTop])
        
        balloon.run(sequence) {
            if balloon.parent != nil {
                balloon.removeFromParent()
            }
        }
        
        let waitAction = SKAction.wait(forDuration: 1.0)
        let spawnAction = SKAction.run { self.spawnBalloon() }
        run(SKAction.sequence([waitAction, spawnAction]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let hitNodes = nodes(at: location)
        if hitNodes.isEmpty {
            self.setLife?()
            print("LIFE")
        } else {
            for node in hitNodes {
                if node.name == "balloon" {
                    animateBalloonPop(balloon: node as! SKSpriteNode)
                    self.setScore?()
                }
            }
        }
    }
    
    func animateBalloonPop(balloon: SKSpriteNode) {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 0.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown, SKAction.removeFromParent()])
        balloon.run(sequence)
    }
    
    func pauseGame() {
        isGamePaused = true
        for i in self.children{
            if i.name == "balloon"{
                i.removeFromParent()
            }
        }
        self.removeAllActions()
    }
    
    func resetScene() {
        removeAllChildren()
        isGamePaused = false
        spawnBalloon()
    }
    
}
