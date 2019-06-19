//
//  QueryEventListener.swift
//  fluttercouch
//
//  Created by Saltech Systems on 5/1/19.
//

import Foundation
import CouchbaseLiteSwift

class QueryEventListener: FlutterStreamHandler {
    var mEventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        mEventSink = events
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        mEventSink = nil
        
        return nil
    }
}

