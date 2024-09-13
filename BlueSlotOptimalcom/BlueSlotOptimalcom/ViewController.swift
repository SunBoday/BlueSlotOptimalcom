//
//  ViewController.swift
//  BlueSlotOptimalcom
//
//  Created by SunTory on 2024/9/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bso_activityView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden  = true
        self.bso_activityView.hidesWhenStopped = true
        self.sqshStartLoad()
        bsoLoadAFListData()
        // Do any additional setup after loading the view.
    }

    @IBAction func clickStartBtn(_ sender: Any) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "BSOHomeVC") as! BSOHomeVC
        let contentVC =  BSONavigationVC.init(rootViewController: gameVC)
        contentVC.modalPresentationStyle = .fullScreen
        present(contentVC, animated: true)
    }
    private func sqshStartLoad() {
        self.bso_activityView.startAnimating()
    }
    
    private func sqshPendLoad() {
        self.bso_activityView.stopAnimating()
    }
    private func bsoLoadAFListData() {
        if let adUrl = UserDefaults.standard.string(forKey: "app_afString"), !adUrl.isEmpty{
            showBSOView()
            return
        }
        
        if BSOBlueNetManager.shared().isReachable {
            bsoReqAFListData()
        } else {
            BSOBlueNetManager.shared().setReachabilityStatusChange { status in
                if BSOBlueNetManager.shared().isReachable {
                    self.bsoReqAFListData()
                    BSOBlueNetManager.shared().stopMonitoring()
                }
            }
            BSOBlueNetManager.shared().startMonitoring()
        }
    }
    
    private func bsoReqAFListData() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        guard let url = URL(string:self.getAFTop() + "/open/getAFListData") else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 请求体数据
        let requestBody: [String: Any] = [
            "appKey": "926e125267414b258429c10c06a4792a",
            "appPackageId": bundleId,
            "appVersion": "1.0"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            fatalError("Error creating request body: \(error)")
        }

        // 执行请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                     // 回到主线程更新 UI
                    self.sqshPendLoad()
                 }

                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                     // 回到主线程更新 UI
                    self.sqshPendLoad()
                 }
                return
            }
            
            do {
                let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                print("Response: \(responseObject)")
                DispatchQueue.main.async {
                     // 回到主线程更新 UI
                    self.sqshPendLoad()
                 }
                if let dictionary = responseObject as? [String: Any] {
                    let dataDic = dictionary["data"] as? [String: Any]
                    if let dataDicQ = dataDic as? [String: Any] {
                        let app_afString = dataDicQ["jsonObject"] as? [String: Any]
                        if let jsonData = try? JSONSerialization.data(withJSONObject: app_afString, options: []),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            UserDefaults.standard.set(jsonString, forKey: "app_afString")
                            if !jsonString.isEmpty {
                                self.showBSOView()
                            } else {
                                DispatchQueue.main.async {
                                     // 回到主线程更新 UI
                                    self.sqshPendLoad()
                                 }                            }

                        } else {
                            print("Failed to convert dictionary to JSON string.")
                        }


                    }
                  
                }
            } catch {
                DispatchQueue.main.async {
                     // 回到主线程更新 UI
                    self.sqshPendLoad()
                 }
                print("Error parsing response data: \(error)")
            }
        }

        task.resume()
    }
}

