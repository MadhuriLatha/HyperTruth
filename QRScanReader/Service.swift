//
//  Service.swift
//  QRScanReader
//
//  Created by Valluri, Madhuri on 2/14/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import Foundation

struct Service {
//    let manufacturerUrl = "http://192.168.2.10:4000/channels/common/chaincodes/reference"
//    let distributorUrl = "http://192.168.2.10:4001/channels/common/chaincodes/reference"
//    let retailerUrl = "http://192.168.2.10:4002/channels/common/chaincodes/reference"
//    let cutsomerUrl = "http://192.168.2.10:4003/channels/common/chaincodes/reference?peer=d%2Fpeer1&fcn=getHistory&args=%22KDL218976-111111%22"
    
    let manufacturerUrl = ":4000/channels/common/chaincodes/reference"
    let distributorUrl = ":4001/channels/common/chaincodes/reference"
    let retailerUrl = ":4002/channels/common/chaincodes/reference"
    let cutsomerUrl = ":4003/channels/common/chaincodes/reference?peer=d%2Fpeer1&fcn=getHistory&args="
    
    //Negative scenarios
//    let cutsomerUrl = "http://192.168.2.10:4003/channels/common/chaincodes/reference?peer=d%2Fpeer1&fcn=getHistory&args=%22KDL244976-2222%22"

}

/*
 [{"key":"Authorization","value":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTc5MzEwMTcsInVzZXJuYW1lIjoiY2hhbGxhIiwib3JnTmFtZSI6Im9yZzEiLCJpYXQiOjE1MTc4OTUwMTd9.78EcX5LXyXDgUO49luug0Uj0sroYK-61p8YJ7ZLyO7o","description":""}]
 
 [{"key":"Content-Type","value":"application/json","description":""}]
 */

//{"peers":["a/peer0","a/peer1","b/peer0","b/peer1","c/peer0","c/peer1","d/peer0","d/peer1"],"fcn":"update","args":["KDL218976","111111","Vinoth","Yoga","0","ORD1111","M","FOXCONN-MEXICO","2017-12-12"]}

//{"peers":["a/peer0","a/peer1","b/peer0","b/peer1","c/peer0","c/peer1","d/peer0","d/peer1"],"fcn":"update","args":["KDL218976","111111","Vinoth","Yoga","0","ORD1111","D","FOXCONN-MEXICO","2017-12-12"]}

//{"peers":["a/peer0","a/peer1","b/peer0","b/peer1","c/peer0","c/peer1","d/peer0","d/peer1"],"fcn":"update","args":["KDL218976","111111","Vinoth","Yoga","0","ORD1111","R","FOXCONN-MEXICO","2017-12-12"]}

/*{
 "transaction": "733c36ffe9e0d0ce2e2669e0c4b6fe6a64116acebdd3e9bd993b52ad3d07ade2"
 }*/



//[{"txId":"69d10071514410ff41a3ab682a5e6dfa1ec2e28a7c5bc9791b16033088dc35de","value":{"ModelNumber":"KDL218976","SerialNumber":"111111","CP":"VINOTH","NP":"CHALLA","CFlag":"0","OrderNo":"ORD1111"}}]

//[{"txId":"69d10071514410ff41a3ab682a5e6dfa1ec2e28a7c5bc9791b16033088dc35de","value":{"ModelNumber":"KDL218976","SerialNumber":"111111","CP":"VINOTH","NP":"CHALLA","CFlag":"0","OrderNo":"ORD1111"}}]
