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
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self
        
        advertiser = MCAdvertiserAssistant(serviceType: "sampler20160822", discoveryInfo: nil, session: session)
        advertiser?.delegate = self
        advertiser?.start()
        
        browser = MCBrowserViewController(serviceType: "sampler20160822", session: session)
        browser.delegate = self
        self.present(browser, animated: true, completion: nil)
    }
    
    
    @IBAction func onClickConnectBtn(_ sender: UIButton) {
        setupSession()
    }
    
    @IBAction func onClickDisconnectBtn(_ sender: UIButton) {
        session.disconnect()
        isConnected = false
        print("disconnected")
    }
    
    @IBAction func onClickSendBtn(_ sender: UIButton) {
        myLabel.text = tf.text
        if isConnected {
            sendData()
        }
    }
    
    func sendData() {
        if session.connectedPeers.count > 0 {
            do {
                let data = tf.text?.data(using: String.Encoding.utf8)
                try session.send(data!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error as NSError {
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
            }
        }
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            isConnected = true
            browser.dismiss(animated: true, completion: nil)
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            isConnected = false
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: String.Encoding.utf8)
         //※point!!（非同期なのでpromiseで認知してあげる必要がある.）
        DispatchQueue.main.async {
            print("data : \(str)")
            self.partnerLabel.text = str
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browser.dismiss(animated: true, completion: nil)
    }
    
    
    // returnボタン押下で閉じる場合
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tf.resignFirstResponder()
        return true
    }
    
    // 画面タップで閉じる場合
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func onClickChangeBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toMCVC", sender: self)
    }
    

}

