//
//  HomeViewController.swift
//  QRScanReader
//
//  Created by myspe2 on 2/7/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit

enum User: String {
    case Manufacturer
    case Distributor
    case Retailer
    case Customer
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var selectedUserType: String!
    var userDataArray = [UserDataModel]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var ipView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var ipAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createUserList()
        tableView.layer.borderWidth = 2.0
        tableView.layer.cornerRadius = 5.0
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func helpAction(_ sender: Any) {
        showIpAddressView()
    }
    
    func showIpAddressView() {
        ipView.isHidden = false
        ipAddressTextField.becomeFirstResponder()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if(ipAddressTextField.text != ""){
            ipAddressTextField.resignFirstResponder()
            saveIpAddressInKeychains(tokenValue: ipAddressTextField.text!)
            ipView.isHidden = true
        }else{
            let alert = UIAlertController(title: "Alert", message: "Add ip address!!!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    self.ipAddressTextField.becomeFirstResponder()
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeIpViewAction(_ sender: Any) {
        ipAddressTextField.resignFirstResponder()
        ipView.isHidden = true
    }
    func createUserList(){
        let model = UserDataModel(user: User.Manufacturer.rawValue, isSelect: false, image: "manufacturer.png")
        userDataArray.append(model)
        let model1 = UserDataModel(user: User.Distributor.rawValue, isSelect: false, image: "distributor.png")
        userDataArray.append(model1)
        let model2 = UserDataModel(user: User.Retailer.rawValue, isSelect: false, image: "retailer.png")
        userDataArray.append(model2)
        let model3 = UserDataModel(user: User.Customer.rawValue, isSelect: false, image: "customer.png")
        userDataArray.append(model3)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TokenEntryViewController
        controller.userType = selectedUserType
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as! HomeTableViewCell
        let model = userDataArray[indexPath.row]
        cell.homeLabel?.text = model.userType
        cell.homeImageView.image = UIImage(named: model.imageNmae)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = userDataArray[indexPath.row]
        model.isSelected = !model.isSelected
        selectedUserType = model.userType
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.ipAddress = getIpAddressFromKeychain()
        performSegue(withIdentifier: "tokenSegue", sender: self)
    }
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ipAddressTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ipAddressTextField.resignFirstResponder()
        saveIpAddressInKeychains(tokenValue: ipAddressTextField.text!)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        ipAddressTextField.resignFirstResponder()
    }
    
    func saveIpAddressInKeychains(tokenValue: String) {
        do {
            // This is a new account, create a new keychain item with the account name.
            let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.ipAddressName,
                                                 account: "ipAddress",
                                                 accessGroup: KeychainConfiguration.accessGroup)
            // Save the password for the new item.
            try tokenItem.savePassword(tokenValue)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func getIpAddressFromKeychain() -> String {
        do {
            let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.ipAddressName,
                                                 account: "ipAddress",
                                                 accessGroup: KeychainConfiguration.accessGroup)
            let keychainToken = try tokenItem.readPassword()
            print("IpAddress: \(keychainToken) of text \(ipAddressTextField.text!)")
            return keychainToken
        }
        catch {
            return "192.168.2.10"
            //            fatalError("Error reading token from keychain - \(error)")
        }
    }
}
