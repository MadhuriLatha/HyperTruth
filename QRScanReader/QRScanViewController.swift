//
//  QRScanViewController.swift
//  QRScanReader
//
//  Created by myspe2 on 1/30/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class QRScanViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var topbar: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var endUserToken: String!
    var requestUserType: String!
    var qrCode = [String]()
    
    var currentLocation: String!
    var currentDateTime: String!
    var transcationId: String!
    var counterField: String = "0"
    var orderId: String!
    var model: String!
    var serialNo: String!
    var responseMessage: String!
    var error: Bool = false
    var historyData = [HistoryDataModel]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        getCurrentLocation()
        addScanCameraView()
        currentDateTime = getCurrentDateAndTime()
//        currentLocation = appDelegate.currentLocation
//        progressView.setProgress(0, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addScanCameraView() {
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: progressView)
        view.bringSubview(toFront: topbar)
        view.bringSubview(toFront: bottomView)
        view.bringSubview(toFront: leftView)
        view.bringSubview(toFront: rightView)

        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        progressView.setProgress(0.0, animated: true)

    }
    
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY  HH:mm"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper methods
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        alertPrompt.popoverPresentationController?.sourceView = self.view
        present(alertPrompt, animated: true, completion: nil)
    }
    
    func getQueryData(_ value: String){
        let tempArr = value.components(separatedBy: ",")
        model = tempArr[0]
        serialNo = tempArr[1]
        doSomethingOnce()
    }
    
    lazy var doSomethingOnce: () -> Void = {
        var url: String!
        if appDelegate.ipAddress != ""{
            url = "http://" + appDelegate.ipAddress
        }
        let service = Service()
        switch requestUserType {
        case "M":
            url = url + service.manufacturerUrl
        case "D":
            url = url + service.distributorUrl
        case "R":
            url = url + service.retailerUrl
        case "C":
            url = url + service.cutsomerUrl
            getAllHistoryRequest(serviceUrl: url)
            return {}
        default:
            break
        }
//        print("Service url::", url)
        makeAlamofireRequest(serviceUrl: url)
        print("executed once")
        
        return {}
    }()
    
    func getBearerToken() -> String {
        var value: String!
        switch requestUserType {
        case "M":
            value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTkzMDcxMzMsInVzZXJuYW1lIjoibWFudWYiLCJvcmdOYW1lIjoiYSIsImlhdCI6MTUxOTI3MTEzM30.pKrwo3FtE657XDPUEI690tViX16n3XxqjQauemt33xw"
        case "D":
            value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTkzMDcxMzgsInVzZXJuYW1lIjoiRGlzdCIsIm9yZ05hbWUiOiJiIiwiaWF0IjoxNTE5MjcxMTM4fQ.U_q-ScjbZszU-lDqSny2M9FFGBKiKI4KJNoZnC_xvJQ"
        case "R":
            value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTkzMDcxMzYsInVzZXJuYW1lIjoiUmV0YWlsIiwib3JnTmFtZSI6ImMiLCJpYXQiOjE1MTkyNzExMzZ9.oloPxRz_hjUi1MUFid912ht8crMDbqjarrDZDt7q2Wo"
        case "C":
            value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTkzMDcxMzQsInVzZXJuYW1lIjoiY3VzdCIsIm9yZ05hbWUiOiJkIiwiaWF0IjoxNTE5MjcxMTM0fQ.5A-QhI5Gk3Ze1V1BhhpYcQaCup0o7H5Lhpj_fkveQi4"
        default:
            break
        }
        return value
    }
    
    func getCurrentPosition() -> String {
        var value: String!
        switch requestUserType {
        case "M":
            value = "Foxconn"
        case "D":
            value = "CARSON WH" //CA
        case "R":
            value = "COSTCO STORE #00056" //SanFrancisco
        default:
            break
        }
        return value
    }
    func getNextPosition() -> String {
        var value: String!
        switch requestUserType {
        case "M"?:
            value = "CARSON WH"
        case "D"?:
            value = "COSTCO STORE #00056"
        case "R"?:
            value = "madhuri.289@gmail.com"
        default:
            break
        }
        return value
    }
    func getLocation() -> String {
        var value: String!

        switch requestUserType {
        case "M"?:
            value = "Mexico"
        case "D"?:
            value = "Carson, CA"
        case "R"?:
            value = "San Francisco, CA"
        case "C"?:
            value = ""
        default:
            break
        }
        return value
    }
    func makeAlamofireRequest(serviceUrl: String) {
        currentLocation = getLocation()
        let headers: HTTPHeaders = ["Authorization":"Bearer \(getBearerToken())"]
        //        let headers: HTTPHeaders = ["Authorization": "Bearer ",\(endUserToken)]
        qrCode = [model,serialNo,getCurrentPosition(),getNextPosition(),counterField,"ORD1111",requestUserType,currentLocation,currentDateTime]
        print("QR code::", qrCode)
        
        if qrCode != nil{
            let parameters: Parameters = [
                "peers":["a/peer0","a/peer1","b/peer0","b/peer1","c/peer0","c/peer1","d/peer0","d/peer1"],
                "fcn": "update",
                "args": qrCode]
            //["KDL818976","111111","Vinoth","Yoga","0","ORD1111",requestUserType,currentLocation,currentDateTime]
            Alamofire.request(URL(string: serviceUrl)!,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: headers).responseJSON{ response in
                                print("Request url:: \(String(describing: response.request?.url)),Request body:: \(String(describing: response.request!.httpBody)), and headers:: \(String(describing: response.request?.allHTTPHeaderFields))")
                                if let JSON = response.result.value {
                                    let responseValue = JSON as! NSDictionary
                                    print("Response:: \(responseValue)")
                                    if responseValue["transaction"] != nil{
                                        self.transcationId = responseValue["transaction"] as! String
                                        self.responseMessage = "Transcation Updated successfully"
                                        self.error = false
                                        self.checkForFaultDevice()
                                    } else if responseValue["ok"] != nil{
                                        if responseValue["ok"] as! Int == 0{
                                            self.responseMessage = "Transcation failed"
                                            self.error = true
                                            self.showResultScreen()
                                        }
                                    }
                                }
                                else {
                                    print(response.result.error!)
                                }
            }
        }
        hideLoadingView()
    }
    
    func getAllHistoryRequest(serviceUrl: String) {
//        currentLocation = getLocation()

        let headers: HTTPHeaders = ["Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTkzMDcxMzQsInVzZXJuYW1lIjoiY3VzdCIsIm9yZ05hbWUiOiJkIiwiaWF0IjoxNTE5MjcxMTM0fQ.5A-QhI5Gk3Ze1V1BhhpYcQaCup0o7H5Lhpj_fkveQi4"]
        
        //                let headers: HTTPHeaders = ["Authorization": "Bearer ",\(endUserToken)]
        let value = "%22" + model + "-" + serialNo + "%22"
        let finalUrl = serviceUrl + value
        Alamofire.request(URL(string: finalUrl)!,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON{ response in
                            print("Request url:: \(String(describing: response.request?.url)),Request body:: \(String(describing: response.request?.httpBody)), and headers:: \(String(describing: response.request?.allHTTPHeaderFields))")
                            if let JSON = response.result.value {
                                print("Response:: \(JSON)")
                                let responseValue = JSON as! NSDictionary
                                if responseValue["result"] != nil{
                                    if responseValue["result"] as! String == "<null>"{
                                        self.responseMessage = "Transcation failed"
                                        self.showResultScreen()
                                    }else{
                                        self.parseHistoryData(data: responseValue["result"] as! Array)
                                        self.showResultScreen()
                                    }
                                } else if responseValue["ok"] != nil{
                                    self.responseMessage = "Transcation failed"
                                    self.error = true
                                    self.showResultScreen()
                                }else{
                                    //Response is null
                                    print("Response is null")
                                    self.responseMessage = "Counterfeit has been identified!!!"
                                    self.error = true
                                    self.showResultScreen()
                                }
                            }
                            else {
                                print(response.result.error!)
                            }
        }
        hideLoadingView()
    }
    
    lazy var checkForFaultDevice: () -> Void = {
        let headers: HTTPHeaders = ["Authorization":"Bearer \(getBearerToken())"]

        //        let headers: HTTPHeaders = ["Authorization": "Bearer ",\(endUserToken)]
        
        let serviceUrl = "http://" + appDelegate.ipAddress + ":4000/channels/common/transactions/" + self.transcationId + "?peer=peer1"
        Alamofire.request(URL(string: serviceUrl)!,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON{ response in
                            print("Request url:: \(String(describing: response.request?.url)),Request body:: \(String(describing: response.request?.httpBody)), and headers:: \(String(describing: response.request?.allHTTPHeaderFields))")
                            if let JSON = response.result.value {
                                let responseValue = JSON as! NSDictionary
                                let envelopeDict = responseValue["transactionEnvelope"] as! NSDictionary
                                let payloadDict = envelopeDict["payload"] as! NSDictionary
                                let dataDict = payloadDict["data"] as! NSDictionary
                                let actionsArr = dataDict["actions"] as! NSArray
                                let firstActionObj = actionsArr[0] as! NSDictionary
                                let payloadInDict = firstActionObj["payload"] as! NSDictionary
                                let actionInDict = payloadInDict["action"] as! NSDictionary
                                let proposalDict = actionInDict["proposal_response_payload"] as! NSDictionary
                                let extensionDict = proposalDict["extension"] as! NSDictionary
                                let resultsDict = extensionDict["results"] as! NSDictionary
                                let nswResultArr = resultsDict["ns_rwset"] as! NSArray
                                let nswResDict = nswResultArr[1] as! NSDictionary
                                let rwsetDict = nswResDict["rwset"] as! NSDictionary
                                let writesArry = rwsetDict["writes"] as! NSArray
                                let valueDict = writesArry[0] as! NSDictionary
                                let finalValueDict = valueDict["value"] as! String
                                print("Final value:: \(finalValueDict)")
                                let finalDict = self.convertToDictionary(text: finalValueDict)
                                if(finalDict!["CFlag"] == "1"){
//                                    self.showAlert()
                                    self.error = true
                                    self.responseMessage = "Counterfeit has been identified!!!"
                                    self.showResultScreen()
                                }else{
                                    self.error = false
                                    self.responseMessage = "Transcation Updated successfully"
                                    self.showResultScreen()
                                }
                            }
                            else {
                                print(response.result.error!)
                            }
        }
        hideLoadingView()
        return{}
    }()
    
    func convertToDictionary(text: String) -> [String: String]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Alert", message: "Counterfeit has been identified!!!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.backToHome()
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func backToHome() {
        dismiss(animated: true, completion: nil)
    }
    
    func parseHistoryData(data:[[String: Any]]) {
        for dict in data{
            if let historyItem = dict["value"] as? [String:Any]{
                let model = HistoryDataModel.init(currentPos: historyItem["CP"] as! String, nextPos: historyItem["NP"] as! String, serialNum: historyItem["SerialNumber"] as! String, modelNum: historyItem["ModelNumber"] as! String, location: historyItem["Location"] as! String, cfFlag: historyItem["CFlag"] as! String, dateTime: historyItem["Date_time"] as! String)
//                model.counterfeitFlag = historyItem["CFlag"] as! String
                self.historyData.append(model)
            }
        }
    }
    func showResultScreen() {
        //navigate to next screen
        performSegue(withIdentifier: "resultSegue", sender: self)
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue"{
            let controller = segue.destination as! ResultViewController
            controller.message = responseMessage
            controller.error = self.error
            controller.historyArray = self.historyData
        }
    }
    
    func showLoadingView() {
        loadingIndicator.isHidden = false
        view.bringSubview(toFront: loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingView() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            progressView.setProgress(0.0, animated: true)
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        progressView.setProgress(0.3, animated: true)

        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            progressView.setProgress(0.6, animated: true)
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            progressView.setProgress(0.8, animated: true)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            progressView.setProgress(1.0, animated: true)

            if metadataObj.stringValue != nil {
                captureSession.stopRunning()
                showLoadingView()
                getQueryData(metadataObj.stringValue!)
                return
            }
        }
    }
    
}


