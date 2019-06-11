//
//  ReplicatorEventListener.swift
//  fluttercouch
//
//  Created by Luca Christille on 25/10/2018.
//

import Foundation
import CouchbaseLiteSwift

class ReplicatorEventListener: FlutterStreamHandler {
    weak var mCBManager : CBManager?
    var mListenerToken: ListenerToken?
    var mEventSink: FlutterEventSink?
    
    init (manager : CBManager) {
        mCBManager = manager
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        mEventSink = events
        mListenerToken = mCBManager?.getReplicator()?.addChangeListener { [weak self] (change) in
            guard let events = self?.mEventSink else {
                return
            }
            
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
            mListenerToken = nil
            mEventSink = nil
            return nil
        }
        
        mCBManager?.getReplicator()?.removeChangeListener(withToken: token)
        mListenerToken = nil
        mEventSink = nil
        return nil
    }
}
