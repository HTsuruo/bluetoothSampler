# bluetoothSampler
ios bluetooth sampler via bluetooth(Multipeer Connectivity Framework).  
send / receive text sample app.

## Framework.
* Multipeer Connectivity Framework

## How to use multipeer connectivity framework
* import
	* ```import MultipeerConnectivity```
* delegate
	* ```MCSessionDelegate```
	* ```MCAdvertiserAssistantDelegate```
	* ```MCBrowserViewControllerDelegate```
* required method
```
func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    switch state {
    case MCSessionState.Connected:
        println("Connected: \(peerID.displayName)")

    case MCSessionState.Connecting:
        println("Connecting: \(peerID.displayName)")

    case MCSessionState.NotConnected:
        println("Not Connected: \(peerID.displayName)")
    }
}

func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
    dispatch_async(dispatch_get_main_queue()) { // ← important
        // do something code
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
```

## References.
* How to create a peer-to-peer network using the multipeer connectivity framework 
	* <https://www.hackingwithswift.com/example-code/system/how-to-create-a-peer-to-peer-network-using-the-multipeer-connectivity-framework>
* P2P 通信を手軽に実現する Multipeer Connectivity Framework を使ってみる（クラスメソッド）
	* <http://dev.classmethod.jp/references/ios-multipeer-apiusage/>