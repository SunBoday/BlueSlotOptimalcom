//
//  BounceVC.swift
//  BlueSlotOptimalcom
//
//  Created by krishnapal sss on 16/09/24.
//
import UIKit
import SpriteKit

class BounceVC: UIViewController {
    
    // Define the back button
    var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
        setupBackButton()
    }
    
    // Set up the SpriteKit game
    func setupGame() {
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        let scene = SimpleBounceSlotGameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    // Set up the back button on screen
    func setupBackButton() {
        backButton = UIButton(frame: CGRect(x: 20, y: 20, width: 50, height: 50))  // Adjust the position and size as needed
        
        backButton.setTitle("←", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.backgroundColor = .white  // Set button color
        backButton.layer.cornerRadius = 10   // Optional: Rounded corners
        backButton.layer.cornerRadius = backButton.frame.size.height/2
        // Add target action to handle the back button tap
        backButton.addTarget(self, action: #selector(btnBackTapped), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(backButton)
    }
    
    // Action for the back button
    @objc func btnBackTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // You can also connect this if using from a Storyboard button
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
