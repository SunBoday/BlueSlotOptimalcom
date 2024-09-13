//
//  BSOLockandKeySlot.swift
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

import UIKit

class BSOLockandKeySlot: UIViewController {

    @IBOutlet weak var bso_lock1Button: UIButton!
    @IBOutlet weak var bso_lock2Button: UIButton!
    @IBOutlet weak var bso_lock3Button: UIButton!
    @IBOutlet weak var bso_lock4Button: UIButton!
    @IBOutlet weak var bso_lock5Button: UIButton!
    @IBOutlet weak var bso_lock6Button: UIButton!

    @IBOutlet weak var bso_key1Button: UIButton!
    @IBOutlet weak var bso_key2Button: UIButton!
    @IBOutlet weak var bso_key3Button: UIButton!
    @IBOutlet weak var bso_key4Button: UIButton!
    @IBOutlet weak var bso_key5Button: UIButton!
    @IBOutlet weak var bso_key6Button: UIButton!

    @IBOutlet weak var totalRewardLabel: UILabel!

    struct Lock {
        var id: Int
        var isUnlocked: Bool = false
        var reward: Int // Reward points
        var keyId: Int // Matching key ID
    }

    var locks: [Lock] = []
    var shuffledLocks: [Lock] = [] // Holds shuffled locks for random display
    var attemptsLeft: Int = 3
    var totalReward: Int = 0
    var selectedKeyId: Int? // Store the selected key ID

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }

    // Setup the game with random rewards and reset everything
    func setupGame() {
        attemptsLeft = 3
        totalReward = 0
        totalRewardLabel.text = "Total Reward: 0"

        // Initialize locks with random rewards and keys
        locks = []
        for i in 0..<6 {
            let reward = (i == 5) ? 0 : Int.random(in: 10...100) // Last lock has no reward (blank)
            locks.append(Lock(id: i, isUnlocked: false, reward: reward, keyId: i))
        }

        // Shuffle the locks and keys
        shuffledLocks = locks.shuffled()
        
        // Reset all UI with shuffled locks and keys
        resetLockButtons()
        resetKeyButtons()
    }

    // Reset all lock buttons to locked state and apply shuffled locks
    func resetLockButtons() {
        let lockImages = ["k1.png", "k2.png", "k3.png", "k4.png", "k5.png", "k6.png"]

        let buttons = [bso_lock1Button, bso_lock2Button, bso_lock3Button, bso_lock4Button, bso_lock5Button, bso_lock6Button]

        for (index, button) in buttons.enumerated() {
            let lock = shuffledLocks[index]
            button?.setImage(UIImage(named: lockImages[lock.id]), for: .normal)
            button?.tag = index // Set the tag as the index to match with keys
        }
    }

    // Reset all key buttons and shuffle them
    func resetKeyButtons() {
        let keyImages = ["1.png", "2.png", "3.png", "4.png", "5.png", "6.png"]

        let buttons = [bso_key1Button, bso_key2Button, bso_key3Button, bso_key4Button, bso_key5Button, bso_key6Button]

        // Shuffle key order and assign new images and tags
        let shuffledKeys = Array(0...5).shuffled()

        for (index, button) in buttons.enumerated() {
            let keyId = shuffledKeys[index]
            button?.setImage(UIImage(named: keyImages[keyId]), for: .normal)
            button?.tag = keyId // Set tag for matching with locks
        }
    }

    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    // Handle key selection
    @IBAction func keySelected(_ sender: UIButton) {
        selectedKeyId = sender.tag
        showAlert(title: "Key Selected", message: "You selected Key \(sender.tag + 1). Now select a lock.")
    }

    // Handle lock selection
    @IBAction func lockSelected(_ sender: UIButton) {
        guard let keyId = selectedKeyId else {
            showAlert(title: "No Key Selected", message: "Please select a key first.")
            return
        }

        let lockId = sender.tag
        let selectedLock = shuffledLocks[lockId]

        // Check if the selected lock has already been unlocked
        if selectedLock.isUnlocked {
            showAlert(title: "Already Unlocked", message: "This lock has already been unlocked.")
            return
        }

        // Check if the selected key matches the lock
        if selectedLock.keyId == keyId {
            unlockLock(lockIndex: lockId)

            if selectedLock.reward == 0 {
                totalReward = 0
                showAlert(title: "Blank Lock!", message: "You unlocked the blank lock. All rewards are lost.")
            } else {
                totalReward += selectedLock.reward
                showAlert(title: "Lock Unlocked!", message: "You unlocked a lock and earned \(selectedLock.reward) points.")
            }
            totalRewardLabel.text = "Total Reward: \(totalReward)"
            shuffledLocks[lockId].isUnlocked = true
        } else {
            // Decrease attempts if the key doesn't match
            attemptsLeft -= 1
            if attemptsLeft <= 0 {
                showAlert(title: "Game Over!", message: "You've used all your attempts. Restarting the game.")
                setupGame()
            } else {
                showAlert(title: "Wrong Key!", message: "This key doesn't match the lock. Attempts left: \(attemptsLeft)")
            }
        }

        // Reset selected key after attempting a lock
        selectedKeyId = nil
    }

    // Unlock the lock by changing its image
    func unlockLock(lockIndex: Int) {
        let unlockedImage = UIImage(named: "k0.png")
        switch lockIndex {
        case 0:
            bso_lock1Button.setImage(unlockedImage, for: .normal)
        case 1:
            bso_lock2Button.setImage(unlockedImage, for: .normal)
        case 2:
            bso_lock3Button.setImage(unlockedImage, for: .normal)
        case 3:
            bso_lock4Button.setImage(unlockedImage, for: .normal)
        case 4:
            bso_lock5Button.setImage(unlockedImage, for: .normal)
        case 5:
            bso_lock6Button.setImage(unlockedImage, for: .normal)
        default:
            break
        }
    }

    // Reset the game when the reset button is pressed
    @IBAction func resetGamePressed(_ sender: UIButton) {
        setupGame()
    }

    // Helper function to show alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
