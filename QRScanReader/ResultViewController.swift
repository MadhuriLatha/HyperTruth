//
//  ResultViewController.swift
//  QRScanReader
//
//  Created by Valluri, Madhuri on 2/19/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var responseMessageview: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var blockchainImageView: UIImageView!
    
    var message: String!
    var error: Bool = false
    var historyArray = [HistoryDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if historyArray.count > 0{
            responseMessageview.isHidden = true
            blockchainImageView.isHidden = true
            historyTableView.isHidden = false
            historyTableView.reloadData()
        }else{
            setResponseMessageView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setResponseMessageView() {
        historyTableView.isHidden = true
        blockchainImageView.isHidden = false
        responseMessageview.isHidden = false
        messageLabel.text = message
        if error {
//            messageImageView.image = UIImage(named: "failure.jpg")
            messageImageView.image = UIImage(named: "counterfeit.jpg")
            messageLabel.textColor = UIColor.red
        }else {
            messageImageView.image = UIImage(named: "success.png")
            messageLabel.textColor = UIColor(displayP3Red: 0.10, green: 0.69, blue: 0.89, alpha: 1.0)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerView") as! HistoryHeaderTableViewCell
        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = historyArray[indexPath.row] as HistoryDataModel
        let historyCell = cell as? HistoryTableViewCell
        historyCell?.serialLabel?.text = model.serialNumber
        historyCell?.modelLabel?.text = model.modelNumber
        historyCell?.currentPosLabel?.text = model.currentPosition
        historyCell?.nextPosLabel?.text = model.nextPosition
        historyCell?.locationLabel?.text = model.location
        historyCell?.dateAndTimeLabel?.text = model.dateAndtime
        
        if model.counterfeitFlag == "1"{
            historyCell?.serialLabel.textColor = UIColor.red
            historyCell?.modelLabel.textColor = UIColor.red
            historyCell?.currentPosLabel.textColor = UIColor.red
            historyCell?.nextPosLabel.textColor = UIColor.red
            historyCell?.locationLabel.textColor = UIColor.red
            historyCell?.dateAndTimeLabel.textColor = UIColor.red
        }
    }
}
