//
//  QueryEventListener.swift
//  fluttercouch
//
//  Created by Saltech Systems on 5/1/19.
//

import Foundation
import CouchbaseLiteSwift

class QueryEventListener: FlutterStreamHandler {
    var mListenerToken: ListenerToken?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let args = arguments as? Dictionary<String,String>, let queryId = args["query"] else {
            return FlutterError(code: "errArgs", message: "Arguments invalid", details: arguments);
        }
        
        if let query = CBManager.instance.getQuery(queryId: queryId) {
            mListenerToken = query.addChangeListener({ (change) in
                var json = Dictionary<String,Any?>()
                json["query"] = queryId
                
                if let results = change.results {
                    json["results"] = QueryJson.resultSetToJson(results: results)
                }
                
                if let error = change.error {
                    json["error"] = error.localizedDescription
                }
                
                events(NSDictionary(dictionary: json as [AnyHashable : Any]))
            })
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let args = arguments as? Dictionary<String,String>, let queryId = args["query"] else {
            return FlutterError(code: "errArgs", message: "Arguments invalid", details: arguments);
        }
        
        if let query = CBManager.instance.getQuery(queryId: queryId), let token = mListenerToken {
            query.removeChangeListener(withToken: token)
        }
        
        mListenerToken = nil
        
        return nil
    }
}

