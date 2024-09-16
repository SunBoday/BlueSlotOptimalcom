//
//  SimpleBounceSlotGameScene.swift
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

import Foundation
import SpriteKit

class SimpleBounceSlotGameScene: SKScene {
    
    var ball: SKShapeNode!
    var slotPositions: [CGPoint] = []
    var slotTargets: [SKShapeNode] = []
    var scoreLabel: SKLabelNode!
    var resultLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var spinButton: SKLabelNode!
    var startGameLabel: SKLabelNode!
    var instructionLabel: SKLabelNode!
    
    var score = 0
    var timeRemaining = 30  // 30 seconds time limit
    let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple, .orange]
    var gameTimer: Timer?
    
    var isGameStarted = false  // To control when the game starts
    
    override func didMove(to view: SKView) {
        setupbg()
        
        showInstructions()  // Show the instructions before the game starts
    }
    
    // Show the How to Play instructions
    func showInstructions() {
        let gameNameLabel = SKLabelNode(fontNamed: "Cochin Bold")
        gameNameLabel.text = "Bounce Slot Game"
        gameNameLabel.fontSize = 36
        gameNameLabel.fontColor = .black
        gameNameLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 150)
        addChild(gameNameLabel)
        
        instructionLabel = SKLabelNode(fontNamed: "Cochin Bold")
        instructionLabel.text = """
        How to Play:
        - Tap to move the ball.
        - Drop the ball into the matching color slot.
        - Use the Spin button to randomize slots.
        - Try to score as much as possible before time runs out!
        """
        instructionLabel.fontSize = 20
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        instructionLabel.numberOfLines = 0
        instructionLabel.preferredMaxLayoutWidth = size.width - 40
        addChild(instructionLabel)
        
        startGameLabel = SKLabelNode(fontNamed: "Cochin Bold")
        startGameLabel.text = "Start Game"
        startGameLabel.fontSize = 30
        startGameLabel.fontColor = .green
        startGameLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        startGameLabel.name = "startGameLabel"
        addChild(startGameLabel)
    }
    func setupbg() {
        let bg = SKSpriteNode(imageNamed: "bg")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -1
        bg.size = size
        addChild(bg)
    }
    
    // Set up slot positions (three slots)
    func setupSlots() {
        // Ensure we have at least 3 unique colors
        let availableColors = colors.shuffled() // Shuffle the colors only once

        // Check if there are at least 3 distinct colors in the colors array
        guard availableColors.count >= 3 else {
            print("Not enough unique colors to assign to slots.")
            return
        }
        
        // Assign the first three distinct colors to the slots
        for i in 0..<3 {
            let slot = SKShapeNode(rectOf: CGSize(width: 80, height: 60), cornerRadius: 10)
            slot.fillColor = availableColors[i]  // Ensure each slot gets a unique color
            slot.position = CGPoint(x: size.width / 2 - CGFloat(100 - i * 100), y: size.height / 2)
            slot.name = "slot\(i)"
            addChild(slot)
            slotPositions.append(slot.position)
            slotTargets.append(slot)
        }
    }


    // Set up the ball that the player controls
    func setupBall() {
        ball = SKShapeNode(circleOfRadius: 30)
        ball.fillColor = colors.randomElement()!
        ball.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(ball)
    }
    
    // Set up the score label
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Cochin Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: size.width / 2 + 200, y: size.height - 50)
        addChild(scoreLabel)
    }
    
    // Set up the result label (match or no match)
    func setupResultLabel() {
        resultLabel = SKLabelNode(fontNamed: "Cochin Bold")
        resultLabel.text = ""
        resultLabel.fontSize = 24
        resultLabel.fontColor = .yellow
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        addChild(resultLabel)
    }
    
    // Set up the timer label
    func setupTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "Cochin Bold")
        timerLabel.text = "Time: \(timeRemaining)"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .black
        timerLabel.position = CGPoint(x: size.width / 2 + 200, y: size.height - 100)
        addChild(timerLabel)
    }
    
    // Set up the spin button
    func setupSpinButton() {
        spinButton = SKLabelNode(fontNamed: "Cochin Bold")
        spinButton.text = "Spin"
        spinButton.fontSize = 30
        spinButton.fontColor = .green
        spinButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        spinButton.name = "spinButton"
        addChild(spinButton)
    }
    
    // Drop the ball into the nearest slot
    func dropBall() {
        let closestSlotIndex = slotPositions.enumerated().min(by: { abs($0.element.x - ball.position.x) < abs($1.element.x - ball.position.x) })!.offset
        
        // Move the ball to the closest slot
        ball.position = CGPoint(x: slotPositions[closestSlotIndex].x, y: size.height / 2 + 50)
        
        // Check if the ball's color matches the slot color
        checkMatch(slotIndex: closestSlotIndex)
        
        // Reset ball to the top with a random color
        resetBall()
    }
    
    // Check if the ball color matches the slot color
    func checkMatch(slotIndex: Int) {
        let slot = slotTargets[slotIndex]
        
        if ball.fillColor == slot.fillColor {
            resultLabel.text = "Correct!"
            score += 10
        } else {
            resultLabel.text = "Try Again!"
        }
        
        scoreLabel.text = "Score: \(score)"
    }
    
    // Reset the ball to the top with a new random color
    func resetBall() {
        ball.position = CGPoint(x: size.width / 2, y: size.height - 100)
        ball.fillColor = colors.randomElement()!
    }
    
    // Spin slots to display new random colors
    func spinSlots() {
        for slot in slotTargets {
            slot.fillColor = colors.randomElement()!
        }
    }
    
    // Start the game timer
    func startGameTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
    }
    
    // Update the game timer
    @objc func updateGameTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            timerLabel.text = "Time: \(timeRemaining)"
        } else {
            gameOver()  // Call gameOver when time runs out
        }
    }
    
    // Handle the game over state
    func gameOver() {
        gameTimer?.invalidate()  // Stop the timer
        resultLabel.text = "Game Over!"
        
        // Remove ball and disable spin button to stop actions
        ball.removeFromParent()
        spinButton.isUserInteractionEnabled = false
        
        // Show restart button
        let restartButton = SKLabelNode(fontNamed: "Cochin Bold")
        restartButton.text = "Restart"
        restartButton.fontSize = 30
        restartButton.fontColor = .blue
        restartButton.position = CGPoint(x: size.width / 2+200, y: size.height / 2 - 100)
        restartButton.name = "restartButton"
        restartButton.zPosition = 100  // Ensure it is visible
        addChild(restartButton)
    }
    
    // Restart the game
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        if tappedNode.name == "restartButton" {
            restartGame()
        }
    }
    
    // Restart the game
    func restartGame() {
        // Clear the current scene and start a new game
        let newScene = SimpleBounceSlotGameScene(size: size)
        view?.presentScene(newScene, transition: SKTransition.flipHorizontal(withDuration: 0.5))
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           guard let touch = touches.first else { return }
           let location = touch.location(in: self)
           let tappedNode = atPoint(location)
           
           if !isGameStarted && tappedNode.name == "startGameLabel" {
               startGame()  // Start the game when Start Game button is tapped
           } else if isGameStarted && tappedNode.name == "spinButton" {
               spinSlots()  // Spin the slots when the Spin button is tapped
           } else if isGameStarted {
               // Move the ball to the touch position (X-axis)
               ball.position.x = location.x
               
               // Drop the ball to the nearest slot
               dropBall()
           }
       }
    // Handle start button tap
   
        // Start the game when the start button is tapped
        func startGame() {
            isGameStarted = true
            startGameLabel.removeFromParent()  // Remove the start button
            instructionLabel.removeFromParent()  // Remove instructions
            setupSlots()
            setupBall()
            setupScoreLabel()
            setupResultLabel()
            setupTimerLabel()
            setupSpinButton()
            startGameTimer()  // Start the game timer
        }
    }
    

