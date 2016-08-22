//
//  ViewController.swift
//  bluetoothSampler
//
//  Created by Tsuru on H28/08/22.
//  Copyright © 平成28年 Tsuru. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCAdvertiserAssistantDelegate, MCBrowserViewControllerDelegate, UITextFieldDelegate  {
    
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant? = nil
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    
    var isConnected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tf.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSession() {
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        
        advertiser = MCAdvertiserAssistant(serviceType: "sampler20160822", discoveryInfo: nil, session: session)
        advertiser?.delegate = self
        advertiser?.start()
        
        browser = MCBrowserViewController(serviceType: "sampler20160822", session: session)
        browser.delegate = self
        self.presentViewController(browser, animated: true, completion: nil)
    }
    
    
    @IBAction func onClickConnectBtn(sender: UIButton) {
        setupSession()
    }
    
    @IBAction func onClickDisconnectBtn(sender: UIButton) {
        session.disconnect()
        isConnected = false
        print("disconnected")
    }
    
    @IBAction func onClickSendBtn(sender: UIButton) {
        myLabel.text = tf.text
        if isConnected {
            sendData()
        }
    }
    
    func sendData() {
        if session.connectedPeers.count > 0 {
            do {
                let data = tf.text?.dataUsingEncoding(NSUTF8StringEncoding)
                try session.sendData(data!, toPeers: session.connectedPeers, withMode: .Reliable)
            } catch let error as NSError {
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            print("Connected: \(peerID.displayName)")
            isConnected = true
            browser.dismissViewControllerAnimated(true, completion: nil)
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            isConnected = false
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: NSUTF8StringEncoding)
         //※point!!（非同期なのでpromiseで認知してあげる必要がある.）
        dispatch_async(dispatch_get_main_queue()) {
            print("data : \(str)")
            self.partnerLabel.text = str
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
    }
    
    func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // returnボタン押下で閉じる場合
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        tf.resignFirstResponder()
        return true
    }
    
    // 画面タップで閉じる場合
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }


}

