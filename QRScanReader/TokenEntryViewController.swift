//
//  TokenEntryViewController.swift
//  QRScanReader
//
//  Created by myspe2 on 2/7/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit

class TokenEntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tokenButton: UIButton!
    
    var finalToken: String!
    var userType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tokenButton.layer.borderWidth = 2.0
        tokenButton.layer.cornerRadius = 5.0
        tokenButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getExistingTokenAction(_ sender: UIButton) {
        finalToken = getTokenFromKeychains()
        if finalToken == ""{
            errorLabel.isHidden = false
        }else{
            //            scanButton.isHidden = false
            goToNextScreen()
        }
    }
    
    @IBAction func backToHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanSegue"{
            let controller = segue.destination as! QRScanViewController
            controller.endUserToken = finalToken
            controller.requestUserType = getRequestUserParam()
        }
    }
    
    func goToNextScreen() {
        performSegue(withIdentifier: "scanSegue", sender: self)
    }
    
    func saveTokenInKeychains(tokenValue: String) {
        do {
            // This is a new account, create a new keychain item with the account name.
            let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                 account: userType,
                                                 accessGroup: KeychainConfiguration.accessGroup)
            // Save the password for the new item.
            try tokenItem.savePassword(tokenValue)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func getTokenFromKeychains() -> String {
        do {
            let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                 account: userType,
                                                 accessGroup: KeychainConfiguration.accessGroup)
            let keychainToken = try tokenItem.readPassword()
            print("Token: \(keychainToken) of user \(userType)")
            return keychainToken
        }
        catch {
            return ""
            //            fatalError("Error reading token from keychain - \(error)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tokenTextField.becomeFirstResponder()
        errorLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveTokenInKeychains(tokenValue: textField.text!)
        finalToken = textField.text
        goToNextScreen()
        return true
    }
    
    func getRequestUserParam() -> String {
        switch userType {
        case User.Manufacturer.rawValue:
            return "M"
        case User.Distributor.rawValue:
            return "D"
        case User.Retailer.rawValue:
            return "R"
        case User.Customer.rawValue:
            return "C"
        default:
            return ""
        }
    }
}
