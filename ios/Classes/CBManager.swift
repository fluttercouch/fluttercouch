//
//  CBManager.swift
//  Runner
//
//  Created by Luca Christille on 14/08/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class CBManager {
    static let instance = CBManager();
    private var mDatabase : Dictionary<String, Database> = Dictionary();
    private var mReplConfig : ReplicatorConfiguration! = nil;
    private var mReplicator : Replicator! = nil;
    private var defaultDatabase = "defaultDatabase";
    
    private init() {}
    
    func getDatabase() -> Database? {
        if let result = mDatabase[defaultDatabase] {
            return result;
        } else {
            return nil;
        }
    }
    
    func getDatabase(name : String) -> Database? {
        if let result = mDatabase[name] {
            return result;
        } else {
            return nil;
        }
    }
    
    func saveDocument(map: Dictionary<String, Any>) throws -> String? {
        let mutableDocument: MutableDocument = MutableDocument(data: map);
        try mDatabase[defaultDatabase]?.saveDocument(mutableDocument)
        return mutableDocument.id;
    }
    
    func saveDocumentWithId(id : String, map: Dictionary<String, Any>) throws -> String? {
        let mutableDocument: MutableDocument = MutableDocument(id: id, data: map)
        try mDatabase[defaultDatabase]?.saveDocument(mutableDocument)
        return mutableDocument.id
    }
    
    func getDocumentWithId(id : String) -> Dictionary<String, Any>? {
        if let defaultDb: Database = getDatabase() {
            if let document: Document = defaultDb.document(withID: id) {
                return document.toDictionary()
            }
        }
        return nil;
    }
    
    func initDatabaseWithName(name: String) -> Database? {
        if let returnedDatabase = mDatabase[name] {
            return returnedDatabase
        } else {
            do {
                let newDatabase = try Database(name: name)
                mDatabase[name] = newDatabase
                defaultDatabase = name
                return newDatabase
            } catch {
                print("Error initializing new database")
            }
        }
        return nil
    }
    
    func setReplicatorEndpoint(endpoint: String) {
        let targetEndpoint = URLEndpoint(url: URL(string: endpoint)!)
        mReplConfig = ReplicatorConfiguration(database: getDatabase()!, target: targetEndpoint)
    }
    
    func setReplicatorType(type: String) -> String {
        if (type == "PUSH") {
            mReplConfig?.replicatorType = .push
        } else if (type == "PULL") {
            mReplConfig?.replicatorType = .pull
        } else if (type == "PUSH_AND_PULL") {
            mReplConfig?.replicatorType = .pushAndPull
        }
        return type
    }
    
    func setReplicatorAuthentication(auth: [String:String]) -> String {
        if let username = auth["username"], let password = auth["password"] {
            mReplConfig?.authenticator = BasicAuthenticator(username: username, password: password)
        }
        return mReplConfig.authenticator.debugDescription
    }
    
    func startReplication() {
        mReplicator = Replicator(config: mReplConfig)
        mReplicator.start()
    }
    
    func stopReplication() {
        mReplicator.stop()
    }
    
}
