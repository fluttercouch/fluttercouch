//
//  CBManager.swift
//  Runner
//
//  Created by Luca Christille on 14/08/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

typealias ExpressionJson = Array<Dictionary<String,Any>>

enum CBManagerError: Error {
    case CertificatePinning
}

protocol CBManagerDelegate : class {
    func lookupKey(forAsset assetKey: String) -> String?
}

class CBManager {
    private var mDatabase : Dictionary<String, Database> = Dictionary();
    private var mQueries : Dictionary<String,Query> = Dictionary();
    private var mQueryListenerTokens : Dictionary<String,ListenerToken> = Dictionary();
    private var mReplConfig : ReplicatorConfiguration?;
    private var mReplicator : Replicator?;
    private var defaultDatabase = "defaultDatabase";
    private var mDBConfig = DatabaseConfiguration();
    private weak var mDelegate: CBManagerDelegate?
    
    init(delegate: CBManagerDelegate, enableLogging: Bool) {
        mDelegate = delegate
        
        guard enableLogging else {
            return
        }
        
        let tempFolder = NSTemporaryDirectory().appending("cbllog")
        Database.log.file.config = LogFileConfiguration(directory: tempFolder)
        Database.log.file.level = .info
    }
    
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
    
    func getDocumentWithId(id : String) -> NSDictionary? {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        if let defaultDb: Database = getDatabase() {
            if let document: Document = defaultDb.document(withID: id) {
                let retrievedDocument: NSDictionary = NSDictionary.init(dictionary: document.toDictionary())
                // It is a repetition due to implementation of Document Dart Class
                resultMap["id"] = id
                resultMap["doc"] = retrievedDocument
            } else {
                resultMap["id"] = id
                resultMap["doc"] = NSDictionary.init()
            }
        }
        return NSDictionary.init(dictionary: resultMap)
    }
    
    func initDatabaseWithName(name: String) throws {
        if mDatabase.keys.contains(name) {
            defaultDatabase = name
        } else {
            let newDatabase = try Database(name: name,config: mDBConfig)
            mDatabase[name] = newDatabase
            defaultDatabase = name
        }
    }
    
    func deleteDatabaseWithName(name: String) throws {
        try Database.delete(withName: name)
    }
    
    func closeDatabaseWithName(name: String) throws {
        if let _db = mDatabase.removeValue(forKey: name) {
            try _db.close()
        }
    }
    
    func addQuery(queryId: String, query: Query, listenerToken: ListenerToken) {
        mQueries[queryId] = query;
        mQueryListenerTokens[queryId] = listenerToken;
    }
    
    func getQuery(queryId: String) -> Query? {
        return mQueries[queryId]
    }
    
    func removeQuery(queryId: String) -> Query? {
        guard let query = mQueries.removeValue(forKey: queryId) else {
            return nil
        }
        
        if let token = mQueryListenerTokens.removeValue(forKey: queryId) {
            query.removeChangeListener(withToken: token)
        }
        
        return query
    }
    
    func buildQuery(options: Dictionary<String,Any>) -> Query? {
        let select : Select
        if let expressionStack = options["selectResult"] as? Array<ExpressionJson> {
            let selectResult = _buildSelect(expressionStack: expressionStack)
            if let selectDistinct = options["selectDisinct"] as? Bool, selectDistinct == true {
                select = QueryBuilder.selectDistinct(selectResult)
            } else {
                select = QueryBuilder.select(selectResult)
            }
        } else {
            return nil
        }
        
        let from: From
        if let dbname = options["from"] as? String, let db = getDatabase(name: dbname) {
            from = select.from(DataSource.database(db))
        } else if let db = getDatabase() {
            from = select.from(DataSource.database(db))
        } else {
            return nil
        }
        
        let whereClause: Where?
        if let whereJson = options["where"] as? ExpressionJson, let whereExpression = _buildExpressionProtocol(expression: whereJson) {
            whereClause = from.where(whereExpression)
        } else {
            whereClause = nil
        }
        
        if let limit = options["limit"] as? ExpressionJson, let limitExpression = _buildExpressionProtocol(expression: limit) {
            if let query = whereClause {
                return query.limit(limitExpression)
            } else {
                return from.limit(limitExpression)
            }
        }

        if let query = whereClause {
            return query
        } else {
            return from
        }
    }
    
    func _buildSelect(expressionStack: Array<ExpressionJson>) -> Array<SelectResultProtocol> {
        var selectResults : Array<SelectResultProtocol> = []
        
        for expression in expressionStack {
            if let result = _buildExpressionProtocol(expression: expression) {
                if (expression.first?.keys.first == "string" && expression.first?.values.first as? String == "all") {
                    selectResults.append(SelectResult.all())
                } else {
                    selectResults.append(SelectResult.expression(result))
                }
            }
        }
        
        return selectResults
    }
    
    func _buildExpressionProtocol(expression: ExpressionJson) -> ExpressionProtocol? {
        var stack : Array<ExpressionProtocol> = []
        
        for jsonObject in expression {
            guard let objectType = jsonObject.keys.first else {
                return nil
            }
            
            switch objectType {
            case "meta":
                if let value = _buildMetaExpressionProtocol(expression: jsonObject) {
                    stack.insert(value, at: 0)
                }
            case "booleanValue":
                if let value = jsonObject[objectType] as? Bool {
                    stack.insert(Expression.boolean(value),at: 0)
                }
            case "doubleValue":
                if let value = jsonObject[objectType] as? Double {
                    stack.insert(Expression.double(value),at: 0)
                }
            case "intValue":
                if let value = jsonObject[objectType] as? Int {
                    stack.insert(Expression.int(value), at: 0)
                }
            case "value":
                stack.insert(Expression.value(jsonObject[objectType]), at: 0)
            case "string":
                stack.insert(Expression.string(jsonObject[objectType] as? String), at: 0)
            case "property":
                if let value = jsonObject[objectType] as? String {
                    stack.insert(Expression.property(value), at: 0)
                }
            case "negated":
                let head = stack.removeFirst()
                stack.insert(Expression.negated(head), at: 0)
            case "not":
                let head = stack.removeFirst()
                stack.insert(Expression.not(head), at: 0)
            case "add":
                let head = stack.removeFirst()
                if let value = jsonObject[objectType] as? ExpressionJson, let otherExpression = _buildExpressionProtocol(expression: value) {
                    stack.insert(head.add(otherExpression), at: 0)
                }
            case "and":
                let head = stack.removeFirst()
                if let value = jsonObject[objectType] as? ExpressionJson, let otherExpression = _buildExpressionProtocol(expression: value) {
                    stack.insert(head.and(otherExpression), at: 0)
                }
            case "from":
                if let value = jsonObject[objectType] as? String {
                    if let head = stack.removeFirst() as? PropertyExpressionProtocol {
                        stack.insert(head.from(value), at: 0)
                    } else if let head = stack.removeFirst() as? MetaExpressionProtocol {
                        stack.insert(head.from(value), at: 0)
                    }
                }
            default:
                return nil
            }
        }
        
        return stack.first
    }
    
    func _buildMetaExpressionProtocol(expression: Dictionary<String, Any>) -> MetaExpressionProtocol? {
        guard let expressionType = expression.keys.first else {
            return nil
        }
        
        switch expressionType {
        case "meta":
            if let value = expression[expressionType] as? String {
                switch value {
                case "id":
                    return Meta.id
                case "isDeleted":
                    return Meta.isDeleted
                case "expiration":
                    return Meta.expiration
                case "sequence":
                    return Meta.sequence
                default:
                    return nil
                }
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    func setReplicatorEndpoint(endpoint: String) {
        let targetEndpoint = URLEndpoint(url: URL(string: endpoint)!)
        mReplConfig = ReplicatorConfiguration(database: getDatabase()!, target: targetEndpoint)
    }
    
    func setReplicatorType(type: String) -> String {
        var settedType: ReplicatorType = ReplicatorType.pull
        if (type == "PUSH") {
            settedType = .push
        } else if (type == "PULL") {
            settedType = .pull
        } else if (type == "PUSH_AND_PULL") {
            settedType = .pushAndPull
        }
        mReplConfig?.replicatorType = settedType
        switch(mReplConfig?.replicatorType.rawValue) {
        case (0):
            return "PUSH_AND_PULL"
        case (1):
            return "PUSH"
        case(2):
            return "PULL"
        default:
            return ""
        }
    }
    
    func setReplicatorAuthentication(auth: [String:String]) -> String {
        if let username = auth["username"], let password = auth["password"] {
            mReplConfig?.authenticator = BasicAuthenticator(username: username, password: password)
        }
        return mReplConfig?.authenticator.debugDescription ?? "Undefined Config"
    }
    
    func setReplicatorSessionAuthentication(sessionID: String?) {
        guard let _sessionID = sessionID, let _mReplConfig = mReplConfig else {
            return;
        }
        
        _mReplConfig.authenticator = SessionAuthenticator(sessionID: _sessionID)
    }
    
    func setReplicatorPinnedServerCertificate(assetKey: String) throws {
        guard let delegate = mDelegate, let _mReplConfig = mReplConfig else {
            return
        }
        
        let key = delegate.lookupKey(forAsset: assetKey)
        
        if let path = Bundle.main.path(forResource: key, ofType: nil), let data = NSData(contentsOfFile: path) {
            _mReplConfig.pinnedServerCertificate = SecCertificateCreateWithData(nil,data)
        } else {
            throw CBManagerError.CertificatePinning
        }
    }
    
    func setReplicatorContinuous(isContinuous: Bool) -> Bool {
        if ((mReplConfig) != nil) {
            mReplConfig?.continuous = isContinuous
            return mReplConfig!.continuous
        }
        return false
    }
    
    func initReplicator() {
        guard let _mReplConfig = mReplConfig else {
            return;
        }
        
        mReplicator = Replicator(config: _mReplConfig)
    }
    
    func startReplication() {
        guard let _mReplicator = mReplicator else {
            return;
        }
        
        _mReplicator.start()
    }
    
    func stopReplication() {
        guard let _mReplicator = mReplicator else {
            return;
        }
        
        _mReplicator.stop()
    }
    
    func getReplicator() -> Replicator? {
        return mReplicator
    }
}
