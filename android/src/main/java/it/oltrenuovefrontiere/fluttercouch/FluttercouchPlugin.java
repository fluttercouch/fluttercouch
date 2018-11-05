package it.oltrenuovefrontiere.fluttercouch;

import android.content.Context;
import android.util.Log;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Query;

import org.json.JSONObject;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.ContentValues.TAG;

/**
 * FluttercouchPlugin
 */
public class FluttercouchPlugin implements MethodCallHandler {

    CBManager mCbManager = CBManager.getInstance();
    static Context context;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        context = registrar.context();
        final FluttercouchPlugin flutterCouchPlugin = new FluttercouchPlugin();
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch");
        channel.setMethodCallHandler(flutterCouchPlugin);

        //final MethodChannel jsonChannel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouchJson", JSONMethodCodec.INSTANCE);
        //jsonChannel.setMethodCallHandler(new FluttercouchPlugin());

        final EventChannel eventChannel = new EventChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch/replicationEventChannel");
        eventChannel.setStreamHandler(new ReplicationEventListener(flutterCouchPlugin.mCbManager));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
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
                    result.success(mCbManager.getDocumentWithId(_id));
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
            case ("setReplicatorSessionAuthentication"):
                String _sessionID = call.arguments();
                try {
                    result.success(mCbManager.setReplicatorSessionAuthentication(_sessionID));
                } catch (Exception e) {
                    e.printStackTrace();;
                    result.error("errAuth", "invalid session ID", null);
                }
                break;
            case ("setReplicatorContinuous"):
                Boolean _continuous = call.arguments();
                try {
                    result.success(mCbManager.setReplicatorContinuous(_continuous));
                } catch (Exception e) {
                    e.printStackTrace();
                    result.error("errContinuous", "unable to set replication to continuous", null);
                }
                break;
            case ("initReplicator"):
                mCbManager.initReplicator();
                result.success("");
                break;
            case ("startReplicator"):
                mCbManager.startReplicator();
                result.success("");
                break;
            case ("stopReplicator"):
                mCbManager.stopReplicator();
                result.success("");
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
            case ("execute"):
                JSONObject queryJson = call.arguments();
                Query queryFromJson = new QueryJson(queryJson).toCouchbaseQuery();
                break;
            default:
                result.notImplemented();
        }
    }
}
