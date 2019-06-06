package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.Query;
import com.couchbase.lite.ResultSet;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.util.List;
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
public class FluttercouchPlugin {
    protected static Registrar registrar;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        FluttercouchPlugin.registrar = registrar;
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch");
        channel.setMethodCallHandler(new CallHander());

        final MethodChannel jsonChannel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouchJson", JSONMethodCodec.INSTANCE);
        jsonChannel.setMethodCallHandler(new JSONCallHander());

        final EventChannel replicationEventChannel = new EventChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch/replicationEventChannel");
        replicationEventChannel.setStreamHandler(new ReplicationEventListener());
    }

    private static class CallHander implements MethodCallHandler {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
            String _name;
            switch (call.method) {
                case ("initDatabaseWithName"):
                    _name = call.arguments();
                    try {
                        CBManager.instance.initDatabaseWithName(_name);
                        result.success(_name);
                    } catch (Exception e) {
                        result.error("errInit", "error initializing database with name " + _name, e.toString());
                    }
                    break;
                case ("closeDatabaseWithName"):
                    _name = call.arguments();
                    try {
                        CBManager.instance.closeDatabaseWithName(_name);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errClose", "error closing database with name " + _name, e.toString());
                    }
                    break;
                case ("deleteDatabaseWithName"):
                    _name = call.arguments();
                    try {
                        CBManager.instance.deleteDatabaseWithName(_name);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errDelete", "error deleting database with name " + _name, e.toString());
                    }
                    break;
                case ("saveDocument"):
                    Map<String, Object> _document = call.arguments();
                    try {
                        String returnedId = CBManager.instance.saveDocument(_document);
                        result.success(returnedId);
                    } catch (CouchbaseLiteException e) {
                        result.error("errSave", "error saving document", e.toString());
                    }
                    break;
                case ("saveDocumentWithId"):
                    if (call.hasArgument("id") && call.hasArgument("map")) {
                        String _id = call.argument("id");
                        Map<String, Object> _map = call.argument("map");
                        try {
                            String returnedId = CBManager.instance.saveDocumentWithId(_id, _map);
                            result.success(returnedId);
                        } catch (CouchbaseLiteException e) {
                            result.error("errSave", "error saving document with id " + _id, e.toString());
                        }
                    } else {
                        result.error("errArg", "invalid arguments", null);
                    }
                    break;
                case ("getDocumentWithId"):
                    String _id = call.arguments();
                    try {
                        result.success(CBManager.instance.getDocumentWithId(_id));
                    } catch (CouchbaseLiteException e) {
                        result.error("errGet", "error getting the document with id: " + _id, e.toString());
                    }
                    break;
                case ("setReplicatorEndpoint"):
                    String _endpoint = call.arguments();
                    try {
                        String _result = CBManager.instance.setReplicatorEndpoint(_endpoint);
                        result.success(_result);
                    } catch (URISyntaxException e) {
                        result.error("errURI", "error setting the replicator endpoint uri to " + _endpoint, e.toString());
                    }
                    break;
                case ("setReplicatorType"):
                    String _type = call.arguments();
                    try {
                        result.success(CBManager.instance.setReplicatorType(_type));
                    } catch (CouchbaseLiteException e) {
                        result.error("errReplType", "error setting replication type to " + _type, e.toString());
                    }
                    break;
                case ("setReplicatorBasicAuthentication"):
                    Map<String, String> _auth = call.arguments();
                    try {
                        result.success(CBManager.instance.setReplicatorBasicAuthentication(_auth));
                    } catch (Exception e) {
                        result.error("errAuth", "error setting authentication for replicator", e.toString());
                    }
                    break;
                case ("setReplicatorSessionAuthentication"):
                    String _sessionID = call.arguments();
                    try {
                        result.success(CBManager.instance.setReplicatorSessionAuthentication(_sessionID));
                    } catch (Exception e) {
                        result.error("errAuth", "invalid session ID", e.toString());
                    }
                    break;
                case ("setReplicatorPinnedServerCertificate"):
                    String assetKey = call.arguments();
                    try {
                        CBManager.instance.setReplicatorPinnedServerCertificate(assetKey);
                        result.success(assetKey);
                    } catch (Exception e) {
                        result.error("errCert", "certificate pinning failed", e.toString());
                    }
                    break;
                case ("setReplicatorContinuous"):
                    Boolean _continuous = call.arguments();
                    try {
                        result.success(CBManager.instance.setReplicatorContinuous(_continuous));
                    } catch (Exception e) {
                        result.error("errContinuous", "unable to set replication to continuous", e.toString());
                    }
                    break;
                case ("initReplicator"):
                    CBManager.instance.initReplicator();
                    result.success("");
                    break;
                case ("startReplicator"):
                    CBManager.instance.startReplicator();
                    result.success("");
                    break;
                case ("stopReplicator"):
                    CBManager.instance.stopReplicator();
                    result.success("");
                    break;
                case ("closeDatabase"):
                    try {
                        Database database = CBManager.instance.getDatabase();
                        database.close();
                        result.success(database.getName());
                    } catch (Exception e) {
                        result.error("errInit", "error closing database", e.toString());
                    }
                    break;
                case ("getDocumentCount"):
                    try {
                        result.success(CBManager.instance.getDocumentCount());
                    } catch (Exception e) {
                        result.error("errGet", "error getting the document count.", e.toString());
                    }
                    break;
                default:
                    result.notImplemented();
            }
        }
    }

    private static class JSONCallHander implements MethodCallHandler {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
            JSONObject queryJson = call.arguments();

            String queryId = "";
            try {
                queryId = queryJson.getString("queryId");
            } catch (JSONException e) {
                result.error("errArg", "Query Error: Invalid Arguments", e);
                return;
            }

            Query queryFromJson;
            switch (call.method) {
                case ("execute"):
                    queryFromJson = CBManager.instance.getQuery(queryId);
                    if (queryFromJson == null) {
                        queryFromJson = new QueryJson(queryJson).toCouchbaseQuery();
                    }

                    try {
                        ResultSet results = queryFromJson.execute();
                        List<Map<String,Object>> resultsList = QueryJson.resultsToJson(results);
                        result.success(resultsList);
                    } catch (CouchbaseLiteException e) {
                        result.error("errExecutingQuery", "error executing query ", e.toString());
                    }
                    break;
                case ("store"):
                    queryFromJson = CBManager.instance.getQuery(queryId);
                    if (queryFromJson == null) {
                        queryFromJson = new QueryJson(queryJson).toCouchbaseQuery();
                        CBManager.instance.addQuery(queryId, queryFromJson);
                        result.success(queryFromJson != null);
                    }

                    final EventChannel queryEventChannel = new EventChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch/queryEventChannel/"+queryId, JSONMethodCodec.INSTANCE);
                    queryEventChannel.setStreamHandler(new QueryEventListener());

                    break;
                case ("remove"):
                    CBManager.instance.removeQuery(queryId);
                    result.success(true);
                    break;
                default:
                    result.notImplemented();
            }
        }
    }
}
