//
//  BSOSlotGame.swift
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

import UIKit
import AVFoundation

class BSOSlotGame: UIViewController {
    
    @IBOutlet weak var bso_reel1: UIPickerView!
    @IBOutlet weak var bso_reel2: UIPickerView!
    @IBOutlet weak var bso_reel3: UIPickerView!
    @IBOutlet weak var bso_spinButton: UIButton!
    @IBOutlet weak var bso_resultLabel: UILabel!
    @IBOutlet weak var bso_scoreLabel: UILabel!
    
    let bso_gemImages = ["A1", "A2", "A3", "A4", "A5", "A6" , "A7" , "A8" ,"A9", "A10","A11","A12"]
    var bso_score = 0
    var bso_spinSoundEffect: AVAudioPlayer?
    var bso_winSoundEffect: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        setupSoundEffects()
        setupButtonAnimations()
        
        bso_reel1.dataSource = self
        bso_reel1.delegate = self
        bso_reel2.dataSource = self
        bso_reel2.delegate = self
        bso_reel3.dataSource = self
        bso_reel3.delegate = self
    }
    
    func setupInitialView() {
        bso_resultLabel.text = ""
        bso_scoreLabel.text = "Score: \(bso_score)"
    }
    
    func setupSoundEffects() {
        if let spinSoundURL = Bundle.main.url(forResource: "spin", withExtension: "wav") {
            do {
                bso_spinSoundEffect = try AVAudioPlayer(contentsOf: spinSoundURL)
                bso_spinSoundEffect?.prepareToPlay()
            } catch {
                print("Error loading spin sound")
            }
        }
        
        if let winSoundURL = Bundle.main.url(forResource: "win", withExtension: "wav") {
            do {
                bso_winSoundEffect = try AVAudioPlayer(contentsOf: winSoundURL)
                bso_winSoundEffect?.prepareToPlay()
            } catch {
                print("Error loading win sound")
            }
        }
    }
    
    func setupButtonAnimations() {
        bso_spinButton.addTarget(self, action: #selector(spinButtonPressed(_:)), for: .touchDown)
        bso_spinButton.addTarget(self, action: #selector(spinButtonReleased(_:)), for: .touchUpInside)
        bso_spinButton.addTarget(self, action: #selector(spinButtonReleased(_:)), for: .touchUpOutside)
    }
    
    @objc func spinButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @objc func spinButtonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func spinButtonTapped(_ sender: UIButton) {
        playSpinSound()
        spinReels()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func spinReels() {
        let reel1Results = bso_gemImages.shuffled()
        let reel2Results = bso_gemImages.shuffled()
        let reel3Results = bso_gemImages.shuffled()
        
        let reel1Row = Int.random(in: 0..<bso_gemImages.count)
        let reel2Row = Int.random(in: 0..<bso_gemImages.count)
        let reel3Row = Int.random(in: 0..<bso_gemImages.count)
        
        bso_reel1.selectRow(reel1Row, inComponent: 0, animated: true)
        bso_reel2.selectRow(reel2Row, inComponent: 0, animated: true)
        bso_reel3.selectRow(reel3Row, inComponent: 0, animated: true)
        
        let reel1Result = bso_gemImages[reel1Row]
        let reel2Result = bso_gemImages[reel2Row]
        let reel3Result = bso_gemImages[reel3Row]
        
        checkForWin(reel1Result: reel1Result, reel2Result: reel2Result, reel3Result: reel3Result)
    }
    
    func checkForWin(reel1Result: String, reel2Result: String, reel3Result: String) {
        if reel1Result == reel2Result && reel2Result == reel3Result {
            bso_score += 100
            bso_resultLabel.text = "Jackpot! Score: +100"
            playWinSound()
        } else if reel1Result == reel2Result || reel2Result == reel3Result || reel1Result == reel3Result {
            bso_score += 50
            bso_resultLabel.text = "Nice! Score: +50"
        } else {
            bso_resultLabel.text = "Try Again!"
        }
        bso_scoreLabel.text = "Score: \(bso_score)"
    }
    
    func playSpinSound() {
        bso_spinSoundEffect?.play()
    }
    
    func playWinSound() {
        bso_winSoundEffect?.play()
    }
}

extension BSOSlotGame: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bso_gemImages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 100))
        imageView.contentMode = .scaleAspectFit
        
        // Ensure image name is valid to avoid empty images
        let imageName = bso_gemImages[row]
        if let image = UIImage(named: imageName) {
            imageView.image = image
        } else {
            imageView.image = nil
        }
        
        imageView.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width - 10, height: 100)
        return imageView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100.0
    }
}
