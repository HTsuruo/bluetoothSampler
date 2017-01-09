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
    
    @IBAction func onClickChangeBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupSession() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
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
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: String.Encoding.utf8)
        //※point!!（非同期なのでpromiseで認知してあげる必要がある.）
        DispatchQueue.main.async {
            print("data : \(str)")
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
    
//    Peer を発見した際に呼ばれるメソッド
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?){
        print("peer discovered")
        print("device : \(peerID.displayName)")
        //発見した Peer へ招待を送る
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
    }
    
//    Peer を見失った際に呼ばれるメソッド
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("peer lost")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //招待を受けるかどうかと自身のセッションを返す
        invitationHandler(true, session)
    }
    
    @IBAction func onClickConnectBtn(_ sender: UIButton) {
        setupSession()
    }
    

}
