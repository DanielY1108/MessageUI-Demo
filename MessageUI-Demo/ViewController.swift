//
//  ViewController.swift
//  MessageUI-Demo
//
//  Created by JINSEOK on 2023/07/11.
//

import UIKit
import MessageUI

class ViewController: UIViewController {
    
    lazy var button: UIButton = {
        let button = UIButton(configuration: .filled())
        button.frame = CGRect(x: 150, y: 400, width: 100, height: 50)
        button.setTitle("문의 사항", for: .normal)
        button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
    }
    
    @objc func buttonHandler(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            let bodyString = """
                             이곳에 내용을 작성해 주세요.
                             
                             
                             ================================
                             Device Model : \(UIDevice.current.modelName)
                             Device OS : \(UIDevice.current.systemVersion)
                             App Version : \(currentAppVersion)
                             ================================
                             """
            
            let bodyStringHTML = """
                                <html>
                                <body>
                                    <h1>내용을 작성해 주세요.</h1><br>
                                    
                                    <p>================================
                                    Device Model : \(UIDevice.current.modelName)<br>
                                    Device OS : \(UIDevice.current.systemVersion)<br>
                                    App Version : \(currentAppVersion)<br>
                                    ===============================</p>
                                </body>
                                </html>
                                """
            
            composeVC.setToRecipients(["scarlet040@gmail.com"])
            composeVC.setSubject("문의 사항")
            composeVC.setMessageBody(bodyString, isHTML: false)
            
            self.present(composeVC, animated: true)
        } else {
            // 만약, 디바이스에 email 기능이 비활성화 일 때, 사용자에게 알림
            let alertController = UIAlertController(title: "메일 계정 활성화 필요",
                                                    message: "Mail 앱에서 사용자의 Email을 계정을 설정해 주세요.",
                                                    preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .default) { _ in
                guard let mailSettingsURL = URL(string: UIApplication.openSettingsURLString + "&&path=MAIL") else { return }
                
                if UIApplication.shared.canOpenURL(mailSettingsURL) {
                    UIApplication.shared.open(mailSettingsURL, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(alertAction)
            
            self.present(alertController, animated: true)
        }
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    // 메일 작성이 끝났을 때, 호출되는 메서드
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            print("메일 보내기 성공")
        case .cancelled:
            print("메일 보내기 취소")
        case .saved:
            print("메일 임시 저장")
        case .failed:
            print("메일 발송 실패")
        @unknown default: break
        }
        
//        self.dismiss(animated: true)
    }
}


// 현재 앱 버전 가져오기
fileprivate var currentAppVersion: String {
    guard let dictionary = Bundle.main.infoDictionary,
          let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
    return version
}


// 디바이스 모델 찾기
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "i386", "x86_64": return "Simulator"
        case "iPhone1,1": return "iPhone"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4S"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5C"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5S"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        default: return identifier
        }
    }
}
