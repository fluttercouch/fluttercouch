//
//  ReplicatorEventListener.swift
//  fluttercouch
//
//  Created by Luca Christille on 25/10/2018.
//

import Foundation
import CouchbaseLiteSwift

class ReplicatorEventListener: FlutterStreamHandler {
    let mCBManager = CBManager.instance
    var mListenerToken: ListenerToken?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        mListenerToken = mCBManager.getReplicator()?.addChangeListener { (change) in
            if let error = change.status.error {
                events(FlutterError(code: "CouchbaseLiteException",message: "Error during replication",details: error.localizedDescription))
            } else {
                switch (change.status.activity) {
                case .busy:
                    events("BUSY")
                case .idle:
                    events("IDLE")
                case .offline:
                    events("OFFLINE")
                case .stopped:
                    events("STOPPED")
                case .connecting:
                    events("CONNECTING")
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let token = mListenerToken else {
            return nil
        }
        
        mCBManager.getReplicator()?.removeChangeListener(withToken: token)
        return nil
    }
}
