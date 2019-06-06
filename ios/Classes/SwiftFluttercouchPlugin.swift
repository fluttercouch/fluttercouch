import Flutter
import UIKit

public class SwiftFluttercouchPlugin: NSObject, FlutterPlugin {
    let mCbManager = CBManager.instance
    static var registrar: FlutterPluginRegistrar?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftFluttercouchPlugin.registrar = registrar
        let channel = FlutterMethodChannel(name: "it.oltrenuovefrontiere.fluttercouch", binaryMessenger: registrar.messenger())
        let instance = SwiftFluttercouchPlugin()
        channel.setMethodCallHandler(instance.handle(_:result:))
        
        let replicatorEventChannel = FlutterEventChannel(name: "it.oltrenuovefrontiere.fluttercouch/replicationEventChannel", binaryMessenger: registrar.messenger())
        replicatorEventChannel.setStreamHandler(ReplicatorEventListener() as? FlutterStreamHandler & NSObjectProtocol)
        
        let jsonMethodChannel = FlutterMethodChannel(name: "it.oltrenuovefrontiere.fluttercouchJson", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        jsonMethodChannel.setMethodCallHandler(instance.handleJson(_:result:))
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "initDatabaseWithName":
            let _name : String = call.arguments! as! String
            do {
                try self.mCbManager.initDatabaseWithName(name: _name)
                result(String(_name))
            } catch {
                result(FlutterError.init(code: "errInit", message: "Error initializing database with name \(_name)", details: error.localizedDescription))
            }
        case "closeDatabaseWithName":
            let _name : String = call.arguments! as! String
            do {
                try self.mCbManager.closeDatabaseWithName(name: _name)
                result(nil)
            } catch {
                result(FlutterError.init(code: "errClose", message: "Error closing database with name \(_name)", details: error.localizedDescription))
            }
        case "deleteDatabaseWithName":
            let _name : String = call.arguments! as! String
            do {
                try self.mCbManager.deleteDatabaseWithName(name: _name)
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
                let returnedId = try self.mCbManager.saveDocument(map: document)
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
                    let returnedId = try self.mCbManager.saveDocumentWithId(id: id!, map: map!)
                    result(returnedId!)
                } catch {
                    result(FlutterError.init(code: "errSave", message: "Error saving document with id \(id!)", details: error.localizedDescription))
                }
            } else {
                result(FlutterError.init(code: "errArgs", message: "Error saving document: Invalid Arguments", details: ""))
            }
        case "getDocumentWithId":
            let id = call.arguments! as! String
            if let returnMap = self.mCbManager.getDocumentWithId(id: id) {
                result(NSDictionary(dictionary: returnMap))
            }
        case "setReplicatorEndpoint":
            let endpoint = call.arguments! as! String
            self.mCbManager.setReplicatorEndpoint(endpoint: endpoint)
            result(String(endpoint))
        case "setReplicatorType":
            let type = call.arguments! as! String
            result(String(self.mCbManager.setReplicatorType(type: type)))
        case "setReplicatorBasicAuthentication":
            let auth = call.arguments! as! [String:String]
            result(String(self.mCbManager.setReplicatorAuthentication(auth: auth)))
        case "setReplicatorSessionAuthentication":
            let sessionID = call.arguments! as! String
            self.mCbManager.setReplicatorSessionAuthentication(sessionID: sessionID)
            result(String(sessionID))
        case "setReplicatorPinnedServerCertificate":
            let assetKey = call.arguments! as! String
            do {
                try self.mCbManager.setReplicatorPinnedServerCertificate(assetKey: assetKey)
                result(String(assetKey))
            } catch {
                result(FlutterError(code: "errCert",message: "Certificate Pinning Failed",details: error.localizedDescription))
            }
        case "setReplicatorContinuous":
            let isContinuous = call.arguments! as! Bool
            result(Bool(self.mCbManager.setReplicatorContinuous(isContinuous: isContinuous)))
        case "initReplicator":
            self.mCbManager.initReplicator()
            result(String(""))
        case "startReplicator":
            self.mCbManager.startReplication()
            result(String(""))
        case "stopReplicator":
            self.mCbManager.stopReplication()
            result(String(""))
        case "closeDatabase":
            if let database = self.mCbManager.getDatabase() {
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
            if let count = self.mCbManager.getDatabase()?.count {
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
        guard let options = call.arguments as? Dictionary<String, Any>, let queryId = options["queryId"] as? String else {
            result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
            return
        }
        
        switch (call.method) {
        case "execute":
            var query = mCbManager.getQuery(queryId: queryId)
            if query == nil {
                query = QueryJson(json: options).toCouchbaseQuery()
            }
            
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
        case "store":
            if let _ = mCbManager.getQuery(queryId: queryId) {
                // DO NOTHING QUERY IS ALREADY STORED
                result(true)
            } else if let query = QueryJson(json: options).toCouchbaseQuery() {
                let queryEventChannel = FlutterEventChannel(name: "it.oltrenuovefrontiere.fluttercouch/queryEventChannel/\(queryId)", binaryMessenger: SwiftFluttercouchPlugin.registrar!.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
                queryEventChannel.setStreamHandler(QueryEventListener() as? FlutterStreamHandler & NSObjectProtocol)
                
                // Store Query for later use
                mCbManager.addQuery(queryId: queryId, query: query)
                result(true)
            } else {
                result(false)
            }
        case "remove":
            let _ = mCbManager.removeQuery(queryId: queryId)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

