package it.oltrenuovefrontiere.fluttercouch;

import android.app.Application;
import android.content.Context;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Query;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FluttercouchPlugin
 */
public class FluttercouchPlugin implements MethodCallHandler {

    CBManager mCbManager = CBManager.getInstance();

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch");
        channel.setMethodCallHandler(new FluttercouchPlugin());
    }

    /**
     * Get ApplicationContext through reflection for database initialization.
     *
     * @return Context
     * @throws Exception
     */

    public static Context getContextFromReflection() throws Exception {
        Application _application = (Application) Class.forName("android.app.ActivityThread").getMethod("currentApplication").invoke(null, (Object[]) null);
        return _application.getApplicationContext();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case ("getPlatformVersion"):
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case ("initDatabaseWithName"):
                String _name = call.arguments();
                try {
                    mCbManager.initDatabaseWithName(_name);
                    result.success(_name);
                } catch (Exception e) {
                    e.printStackTrace();
                    result.error("errInit", "error initializing database", e.toString());
                }
                break;
            case ("saveDocument"):
                Map<String, Object> _document = call.arguments();
                try {
                    String returnedId = mCbManager.saveDocument(_document);
                    result.success(returnedId);
                } catch (CouchbaseLiteException e) {
                    e.printStackTrace();
                    result.error("errSave", "error saving the document", e.toString());
                }
                break;
            case ("saveDocumentWithId"):
                if (call.hasArgument("id") && call.hasArgument("map")) {
                    String _id = call.argument("id");
                    Map<String, Object> _map = call.argument("map");
                    try {
                        String returnedId = mCbManager.saveDocumentWithId(_id, _map);
                        result.success(returnedId);
                    } catch (CouchbaseLiteException e) {
                        e.printStackTrace();
                        result.error("errSave", "error saving the document", e.toString());
                    }
                } else {
                    result.error("errArg", "invalid arguments", null);
                }
                break;
            case ("getDocumentWithId"):
                String _id = call.arguments();
                try {
                    HashMap<String, Object> _map = new HashMap<>();
                    _map.put("doc", mCbManager.getDocumentWithId(_id));
                    _map.put("id", _id); // Is a bit redundant, but is necessary for standard return data in dart implementation
                    result.success(_map);
                } catch (CouchbaseLiteException e) {
                    e.printStackTrace();
                    result.error("errGet", "error getting the document with id: " + _id, e.toString());
                }
                break;
            case ("setReplicatorEndpoint"):
                String _endpoint = call.arguments();
                try {
                    String _result = mCbManager.setReplicatorEndpoint(_endpoint);
                    result.success(_result);
                } catch (URISyntaxException e) {
                    e.printStackTrace();
                    result.error("errURI", "error setting the replicator endpoint uri to " + _endpoint, e.toString());
                }
                break;
            case ("setReplicatorType"):
                String _type = call.arguments();
                try {
                    result.success(mCbManager.setReplicatorType(_type));
                } catch (CouchbaseLiteException e) {
                    e.printStackTrace();
                    result.error("errReplType", "error setting replication type to " + _type, e.toString());
                }
                break;
            case ("setReplicatorBasicAuthentication"):
                Map<String, String> _auth = call.arguments();
                try {
                    result.success(mCbManager.setReplicatorBasicAuthentication(_auth));
                } catch (Exception e) {
                    e.printStackTrace();
                    result.error("errAuth", "error setting authentication for replicator", null);
                }
                break;
            case ("startReplicator"):
                mCbManager.startReplicator();
                break;
            case ("stopReplicator"):
                mCbManager.stopReplicator();
                break;
            case ("executeQuery"):
                HashMap<String, String> _queryMap = call.arguments();
                Query query = QueryManager.buildFromMap(_queryMap, mCbManager);
                try {
                    result.success(query.explain());
                } catch (CouchbaseLiteException e) {
                    e.printStackTrace();
                    result.error("errExecutingQuery", "error executing query ", e.toString());
                }
                break;
            default:
                result.notImplemented();
        }
    }
}
