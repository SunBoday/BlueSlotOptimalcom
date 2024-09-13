//
//  BSONavigationVC.swift
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

import UIKit

class BSONavigationVC: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        // Set shadow image to a blank UIImage
        navigationBar.shadowImage = UIImage()
        
        // Make the navigation bar translucent
        navigationBar.isTranslucent = true
            
        navigationBar.tintColor = UIColor.white
        // 设置导航栏标题颜色为白色
         navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        setNavigationBarHidden(true, animated: false)

        // Do any additional setup after loading the view.
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    override var shouldAutorotate: Bool {
        return true
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
