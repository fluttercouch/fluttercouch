import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let mCbManager = CBManager.instance
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let fluttercouchChannel = FlutterMethodChannel.init(name: "it.oltrenuovefrontiere.fluttercouch", binaryMessenger: controller);
    
    fluttercouchChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) in
        switch (call.method) {
        case "initDatabaseWithName":
            let name : String = call.arguments! as! String
            let resultName = self.mCbManager.initDatabaseWithName(name: name)
            result(resultName?.name ?? "")
        case "saveDocument":
            let document = call.arguments! as! [String:Any]
            do {
                let returnedId = try self.mCbManager.saveDocument(map: document)
                result(returnedId!)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: ""))
            }
        case "saveDocumentWithId":
            let arguments = call.arguments! as! [String:Any]
            let id = arguments["id"] as! String?
            let map = arguments["map"] as! [String: String]?
            if (id != nil && map != nil){
                do {
                    let returnedId = try self.mCbManager.saveDocumentWithId(id: id!, map: map!)
                    result(returnedId!)
                } catch {
                    result(FlutterError.init(code: "errSave", message: "Error saving document with id \(id!)", details: ""))
                }
            } else {
                result(FlutterError.init(code: "errArgs", message: "Error saving document: Invalid Arguments", details: ""))
            }
        case "getDocumentWithId":
            let id = call.arguments! as! String
            if var returnMap = self.mCbManager.getDocumentWithId(id: id) {
                returnMap["id"] = id
                result(returnMap)
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
        case "startReplicator":
            self.mCbManager.startReplication()
        case "stopReplicator":
            self.mCbManager.stopReplication()
        default:
            result(FlutterMethodNotImplemented)
    }
    };
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
