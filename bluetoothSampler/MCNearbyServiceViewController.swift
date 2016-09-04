//
//  MCNearbyServiceViewController.swift
//  bluetoothSampler
//
//  Created by Tsuru on H28/09/04.
//  Copyright © 平成28年 Tsuru. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MCNearbyServiceViewController: UIViewController, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {

    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCNearbyServiceBrowser!
    var advertiser:MCNearbyServiceAdvertiser? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickChangeBtn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupSession() {
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "sampler20160822")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "sampler20160822")
        browser.delegate = self;
        browser.startBrowsingForPeers()
    }
    
    func sendData() {
        if session.connectedPeers.count > 0 {
            do {
//            let data = tf.text?.dataUsingEncoding(NSUTF8StringEncoding)
//            try session.sendData(data!, toPeers: session.connectedPeers, withMode: .Reliable)
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
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: NSUTF8StringEncoding)
        //※point!!（非同期なのでpromiseで認知してあげる必要がある.）
        dispatch_async(dispatch_get_main_queue()) {
            print("data : \(str)")
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
    
//    Peer を発見した際に呼ばれるメソッド
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?){
        print("peer discovered")
        print("device : \(peerID.displayName)")
        //発見した Peer へ招待を送る
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 0)
    }
    
//    Peer を見失った際に呼ばれるメソッド
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("peer lost")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser,didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        //招待を受けるかどうかと自身のセッションを返す
        invitationHandler(true, session)
    }
    
    @IBAction func onClickConnectBtn(sender: UIButton) {
        setupSession()
    }
    

}
