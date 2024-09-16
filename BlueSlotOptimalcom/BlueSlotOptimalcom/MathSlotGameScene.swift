//
//  MathSlotGameScene.swift
//  BlueSlotOptimalcom
//
//  Created by krishnapal sss on 16/09/24.
//

import Foundation
import SpriteKit

class MathSlotGameScene: SKScene {
    
    let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let operators = ["+", "-", "*", "/"]
    var slotItems: [SKLabelNode] = []
    
    var spinButton: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var resultLabel: SKLabelNode!
    
    var answerTextField: UITextField!
    var progressBar: UIProgressView!
    var timerLabel: SKLabelNode!
    
    var score = 0
    var currentAnswer: Double?  // Stores the correct answer as a Double to handle floating-point division
    var gameTimer: Timer!
    var progress: Float = 1.0
    var overallTimeLimit: Int = 60  // Overall game time limit in seconds
    
    override func didMove(to view: SKView) {
        setupbg()
        setupSlots()
        setupSpinButton()
        setupScoreLabel()
        setupResultLabel()
        setupAnswerTextField()
  
        setupTimerLabel()
        startGameTimer()
    }
    
    func setupbg() {
        let bg = SKSpriteNode(imageNamed: "bg")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -1
        bg.size = size
        addChild(bg)
    }
    
    // Setup the slot machine (three slots)
    func setupSlots() {
        for i in 0..<3 {
            let background = SKShapeNode(rectOf: CGSize(width: 80, height: 60), cornerRadius: 10)
            background.fillColor = .blue
            background.position = CGPoint(x: size.width / 2 - CGFloat(100 - i * 100), y: size.height / 2)
            
            let slot = SKLabelNode(fontNamed: "Cochin Bold")
            slot.fontSize = 40
            slot.text = "?"
            slot.fontColor = .white
            slot.position = CGPoint(x: 0, y: -slot.frame.height / 2)
            
            background.addChild(slot)
            addChild(background)
            slotItems.append(slot)
        }
    }

    // Setup the spin button
    func setupSpinButton() {
        spinButton = SKLabelNode(fontNamed: "Cochin Bold")
        spinButton.text = "Spin"
        spinButton.fontSize = 40
        spinButton.fontColor = .green
        spinButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        spinButton.name = "spinButton"
        addChild(spinButton)
    }
    
    // Setup the score label
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Cochin Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(scoreLabel)
    }
    
    // Setup the result label
    func setupResultLabel() {
        resultLabel = SKLabelNode(fontNamed: "Cochin Bold")
        resultLabel.text = ""
        resultLabel.fontSize = 24
        resultLabel.fontColor = .red
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        addChild(resultLabel)
    }
    
    // Setup the answer text field
    func setupAnswerTextField() {
        answerTextField = UITextField(frame: CGRect(x: view!.frame.midX + 150, y: view!.frame.midY - 100, width: 150, height: 40))
        answerTextField.placeholder = "Enter answer"
        answerTextField.borderStyle = .roundedRect
        answerTextField.backgroundColor = .white
        answerTextField.textAlignment = .center
        answerTextField.keyboardType = .decimalPad
        answerTextField.isHidden = true
        view?.addSubview(answerTextField)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Check", style: .done, target: self, action: #selector(checkAnswer))
        toolbar.setItems([doneButton], animated: true)
        answerTextField.inputAccessoryView = toolbar
    }
    
   
    
    // Setup the timer label
    func setupTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "Cochin Bold")
        timerLabel.text = "Time: \(overallTimeLimit)"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .black
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(timerLabel)
    }
    
    // Start the overall game timer
    func startGameTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateOverallGameTimer), userInfo: nil, repeats: true)
    }
    
    // Update the overall game timer
    @objc func updateOverallGameTimer() {
        if overallTimeLimit > 0 {
            overallTimeLimit -= 1
            timerLabel.text = "Time: \(overallTimeLimit)"
        } else {
            gameOver()
        }
    }
    
    // Handle user touches (spin the slot machine)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        if tappedNode.name == "spinButton" {
            checkAnswer()
            spinSlots()
        }
    }
    
    // Spin the slot machine and prepare for answer input
    func spinSlots() {
        resultLabel.text = ""
        
        let firstNumber = numbers.randomElement()!
        let operatorSymbol = operators.randomElement()!
        let secondNumber = numbers.randomElement()!
        
        slotItems[0].text = "\(firstNumber)"
        slotItems[1].text = operatorSymbol
        slotItems[2].text = "\(secondNumber)"
        
        currentAnswer = calculateAnswer(firstNumber: firstNumber, operatorSymbol: operatorSymbol, secondNumber: secondNumber)
        
        answerTextField.isHidden = false
        answerTextField.becomeFirstResponder()
    }
    
    // Calculate the correct answer for the math equation
    func calculateAnswer(firstNumber: Int, operatorSymbol: String, secondNumber: Int) -> Double? {
        var result: Double?
        switch operatorSymbol {
        case "+":
            result = Double(firstNumber + secondNumber)
        case "-":
            result = Double(firstNumber - secondNumber)
        case "*":
            result = Double(firstNumber * secondNumber)
        case "/":
            if secondNumber != 0 {
                result = Double(firstNumber) / Double(secondNumber)
            }
        default:
            break
        }
        return result
    }
    // Check if the inputted answer is correct
    @objc func checkAnswer() {
        if let input = answerTextField.text, let userAnswer = Double(input), let correctAnswer = currentAnswer {
            if abs(userAnswer - correctAnswer) < 0.01 {
                resultLabel.text = "Correct!"
                score += 10
                progress = min(progress + 0.1, 1.0)  // Increase progress bar by 10% for each correct answer
              //  progressBar.setProgress(progress, animated: true)  // Update the progress bar
            } else {
                resultLabel.text = "Wrong!"
            }
        } else {
            resultLabel.text = "Invalid input!"
        }

        // Update score and reset the game state for the next round
        scoreLabel.text = "Score: \(score)"
        answerTextField.text = ""
        answerTextField.isHidden = true
        answerTextField.resignFirstResponder()
    }

 
    // End the game when the progress bar is depleted
    func gameOver() {
        gameTimer.invalidate()
        resultLabel.text = "Game Over!"
        answerTextField.isHidden = true
        answerTextField.resignFirstResponder()
        
        // Show a restart option
        let restartButton = SKLabelNode(fontNamed: "Cochin Bold")
        restartButton.text = "Restart"
        restartButton.fontSize = 40
        restartButton.fontColor = .blue
        restartButton.position = CGPoint(x: size.width / 2+200, y: size.height / 2 - 100)
        restartButton.name = "restartButton"
        addChild(restartButton)
    }
    
    // Restart the game when the user taps the restart button
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
         let newScene = MathSlotGameScene(size: size)
         view?.presentScene(newScene, transition: SKTransition.flipHorizontal(withDuration: 0.5))
     }
    
}


