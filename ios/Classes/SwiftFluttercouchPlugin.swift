import Flutter
import UIKit

public class SwiftFluttercouchPlugin: NSObject, FlutterPlugin, CBManagerDelegate {
    weak var mRegistrar: FlutterPluginRegistrar?
    let mQueryEventListener = QueryEventListener();
    let databaseDispatchQueue = DispatchQueue(label: "DatabaseDispatchQueue", qos: .background)
    
    #if DEBUG
    lazy var mCBManager = CBManager(delegate: self, enableLogging: true)
    #else
    lazy var mCBManager = CBManager(delegate: self, enableLogging: false)
    #endif
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFluttercouchPlugin(registrar: registrar)
        
        let channel = FlutterMethodChannel(name: "it.oltrenuovefrontiere.fluttercouch", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler(instance.handle(_:result:))
        
        let jsonMethodChannel = FlutterMethodChannel(name: "it.oltrenuovefrontiere.fluttercouchJson", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        jsonMethodChannel.setMethodCallHandler(instance.handleJson(_:result:))
        
        let replicatorEventChannel = FlutterEventChannel(name: "it.oltrenuovefrontiere.fluttercouch/replicationEventChannel", binaryMessenger: registrar.messenger())
        replicatorEventChannel.setStreamHandler(ReplicatorEventListener(manager: instance.mCBManager) as? FlutterStreamHandler & NSObjectProtocol)
        
        let queryEventChannel = FlutterEventChannel(name: "it.oltrenuovefrontiere.fluttercouch/queryEventChannel", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        queryEventChannel.setStreamHandler(instance.mQueryEventListener as? FlutterStreamHandler & NSObjectProtocol)
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        
        mRegistrar = registrar
    }
    
    func lookupKey(forAsset assetKey: String) -> String? {
        return mRegistrar?.lookupKey(forAsset: assetKey)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "initDatabaseWithName":
            let _name : String = call.arguments! as! String
            do {
                try mCBManager.initDatabaseWithName(name: _name)
                result(String(_name))
            } catch {
                result(FlutterError.init(code: "errInit", message: "Error initializing database with name \(_name)", details: error.localizedDescription))
            }
        case "closeDatabaseWithName":
            let _name : String = call.arguments! as! String
            do {
                try mCBManager.closeDatabaseWithName(name: _name)
                result(_name)
            } catch {
                result(FlutterError.init(code: "errClose", message: "Error closing database with name \(_name)", details: error.localizedDescription))
            }
        case "deleteDatabaseWithName":
            let _name : String = call.arguments! as! String
            do {
                try mCBManager.deleteDatabaseWithName(name: _name)
                result(nil)
            } catch {
                result(FlutterError.init(code: "errDelete", message: "Error deleting database with name \(_name)", details: error.localizedDescription))
            }
        case "saveDocument":
            guard let document = DataConverter.convertSETDictionary(call.arguments as! [String : Any]?) else {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: ""))
                return
            }
            
            do {
                let returnedId = try mCBManager.saveDocument(map: document)
                result(returnedId!)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: error.localizedDescription))
            }
        case "saveDocumentWithId":
            let arguments = call.arguments! as! [String:Any]
            let id = arguments["id"] as! String?
            let map = DataConverter.convertSETDictionary(arguments["map"] as! [String:Any]?)
            
            if (id != nil && map != nil){
                do {
                    let returnedId = try mCBManager.saveDocumentWithId(id: id!, map: map!)
                    result(returnedId!)
                } catch {
                    result(FlutterError.init(code: "errSave", message: "Error saving document with id \(id!)", details: error.localizedDescription))
                }
            } else {
                result(FlutterError.init(code: "errArgs", message: "Error saving document: Invalid Arguments", details: ""))
            }
        case "getDocumentWithId":
            let id = call.arguments! as! String
            if let returnMap = mCBManager.getDocumentWithId(id: id) {
                result(NSDictionary(dictionary: returnMap))
            }
        case "setReplicatorEndpoint":
            let endpoint = call.arguments! as! String
            mCBManager.setReplicatorEndpoint(endpoint: endpoint)
            result(nil)
        case "setReplicatorType":
            let type = call.arguments! as! String
            mCBManager.setReplicatorType(type: type)
            result(nil)
        case "setReplicatorBasicAuthentication":
            let auth = call.arguments! as! [String:String]
            mCBManager.setReplicatorAuthentication(auth: auth)
            result(nil)
        case "setReplicatorSessionAuthentication":
            let sessionID = call.arguments! as! String
            mCBManager.setReplicatorSessionAuthentication(sessionID: sessionID)
            result(nil)
        case "setReplicatorPinnedServerCertificate":
            let assetKey = call.arguments! as! String
            do {
                try mCBManager.setReplicatorPinnedServerCertificate(assetKey: assetKey)
                result(nil)
            } catch {
                result(FlutterError(code: "errCert",message: "Certificate Pinning Failed",details: error.localizedDescription))
            }
        case "setReplicatorContinuous":
            let isContinuous = call.arguments! as! Bool
            mCBManager.setReplicatorContinuous(isContinuous: isContinuous)
            result(nil)
        case "initReplicator":
            mCBManager.initReplicator()
            result(nil)
        case "startReplicator":
            mCBManager.startReplication()
            result(nil)
        case "stopReplicator":
            mCBManager.stopReplication()
            result(nil)
        case "closeDatabase":
            if let database = mCBManager.getDatabase() {
                do {
                    try database.close()
                    result(database.name)
                } catch {
                    result(FlutterError.init(code: "errClose", message: "Error closing database with name \(database.name)", details: error.localizedDescription))
                }
            } else {
                result(String(""))
            }
        case "getDocumentCount":
            if let count = mCBManager.getDatabase()?.count {
                result(count)
            } else {
                result(0)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func handleJson(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        /* call.arguments:
         * Supported messages are acyclic values of these forms: null, bools, nums,
         * Strings, Lists of supported values, Maps from strings to supported values
         **/
        
        switch (call.method) {
        case "executeQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            let query = mCBManager.getQuery(queryId: queryId) ?? QueryJson(json: options, manager: mCBManager).toCouchbaseQuery()
            
            databaseDispatchQueue.async {
                do {
                    if let results = try query?.execute() {
                        let json = QueryJson.resultSetToJson(results: results)
                        result(json)
                    } else {
                        result(FlutterError(code: "errQuery", message: "Error executing query", details: "Something went wrong with the query"))
                    }
                } catch {
                    result(FlutterError(code: "errQuery", message: "Error executing query", details: error.localizedDescription))
                }
            }
        case "storeQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            if let _ = mCBManager.getQuery(queryId: queryId) {
                // DO NOTHING QUERY IS ALREADY STORED
                result(true)
            } else if let query = QueryJson(json: options, manager: mCBManager).toCouchbaseQuery() {
                // Store Query for later use
                let token = query.addChangeListener(withQueue: databaseDispatchQueue) { [weak self] change in
                    var json = Dictionary<String,Any?>()
                    json["query"] = queryId
                    
                    if let results = change.results {
                        json["results"] = QueryJson.resultSetToJson(results: results)
                    }
                    
                    if let error = change.error {
                        json["error"] = error.localizedDescription
                    }
                    
                    // Will only send events when there is something listening
                    self?.mQueryEventListener.mEventSink?(NSDictionary(dictionary: json as [AnyHashable : Any]))
                }
                
                mCBManager.addQuery(queryId: queryId, query: query, listenerToken: token)
                result(true)
            } else {
                result(false)
            }
        case "removeQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            let _ = mCBManager.removeQuery(queryId: queryId)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

