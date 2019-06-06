package it.oltrenuovefrontiere.fluttercouch;

import android.content.Context;
import android.content.res.AssetManager;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.Query;
import com.couchbase.lite.QueryChange;
import com.couchbase.lite.QueryChangeListener;
import com.couchbase.lite.ResultSet;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FluttercouchPlugin
 */
public class FluttercouchPlugin implements CBManagerDelegate {
    private final Registrar mRegistrar;
    private final QueryEventListener mQueryEventListener = new QueryEventListener();
    private final CBManager mCBManager;
    private CallHander callHander = new CallHander();
    private JSONCallHandler jsonCallHandler = new JSONCallHandler();

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        FluttercouchPlugin instance = new FluttercouchPlugin(registrar);

        final MethodChannel channel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch");
        channel.setMethodCallHandler(instance.callHander);

        final MethodChannel jsonChannel = new MethodChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouchJson", JSONMethodCodec.INSTANCE);
        jsonChannel.setMethodCallHandler(instance.jsonCallHandler);

        final EventChannel replicationEventChannel = new EventChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch/replicationEventChannel");
        replicationEventChannel.setStreamHandler(new ReplicationEventListener(instance.mCBManager));

        final EventChannel queryEventChannel = new EventChannel(registrar.messenger(), "it.oltrenuovefrontiere.fluttercouch/queryEventChannel", JSONMethodCodec.INSTANCE);
        queryEventChannel.setStreamHandler(instance.mQueryEventListener);
    }

    public FluttercouchPlugin(Registrar registrar) {
        super();

        mRegistrar = registrar;

        if (BuildConfig.DEBUG) {
            mCBManager = new CBManager(this,true);
        } else {
            mCBManager = new CBManager(this,false);
        }
    }

    @Override
    public String lookupKeyForAsset(String asset) {
        return mRegistrar.lookupKeyForAsset(asset);
    }

    @Override
    public AssetManager getAssets() {
        return mRegistrar.context().getAssets();
    }

    @Override
    public Context getContext() {
        return mRegistrar.context();
    }

    private class CallHander implements MethodCallHandler {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
            String _name;
            switch (call.method) {
                case ("initDatabaseWithName"):
                    _name = call.arguments();
                    try {
                        mCBManager.initDatabaseWithName(_name);
                        result.success(_name);
                    } catch (Exception e) {
                        result.error("errInit", "error initializing database with name " + _name, e.toString());
                    }
                    break;
                case ("closeDatabaseWithName"):
                    _name = call.arguments();
                    try {
                        mCBManager.closeDatabaseWithName(_name);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errClose", "error closing database with name " + _name, e.toString());
                    }
                    break;
                case ("deleteDatabaseWithName"):
                    _name = call.arguments();
                    try {
                        mCBManager.deleteDatabaseWithName(_name);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errDelete", "error deleting database with name " + _name, e.toString());
                    }
                    break;
                case ("saveDocument"):
                    Map<String, Object> _document = call.arguments();
                    try {
                        String returnedId = mCBManager.saveDocument(_document);
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
                            String returnedId = mCBManager.saveDocumentWithId(_id, _map);
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
                        result.success(mCBManager.getDocumentWithId(_id));
                    } catch (CouchbaseLiteException e) {
                        result.error("errGet", "error getting the document with id: " + _id, e.toString());
                    }
                    break;
                case ("setReplicatorEndpoint"):
                    String _endpoint = call.arguments();
                    try {
                        String _result = mCBManager.setReplicatorEndpoint(_endpoint);
                        result.success(_result);
                    } catch (URISyntaxException e) {
                        result.error("errURI", "error setting the replicator endpoint uri to " + _endpoint, e.toString());
                    }
                    break;
                case ("setReplicatorType"):
                    String _type = call.arguments();
                    try {
                        result.success(mCBManager.setReplicatorType(_type));
                    } catch (CouchbaseLiteException e) {
                        result.error("errReplType", "error setting replication type to " + _type, e.toString());
                    }
                    break;
                case ("setReplicatorBasicAuthentication"):
                    Map<String, String> _auth = call.arguments();
                    try {
                        result.success(mCBManager.setReplicatorBasicAuthentication(_auth));
                    } catch (Exception e) {
                        result.error("errAuth", "error setting authentication for replicator", e.toString());
                    }
                    break;
                case ("setReplicatorSessionAuthentication"):
                    String _sessionID = call.arguments();
                    try {
                        result.success(mCBManager.setReplicatorSessionAuthentication(_sessionID));
                    } catch (Exception e) {
                        result.error("errAuth", "invalid session ID", e.toString());
                    }
                    break;
                case ("setReplicatorPinnedServerCertificate"):
                    String assetKey = call.arguments();
                    try {
                        mCBManager.setReplicatorPinnedServerCertificate(assetKey);
                        result.success(assetKey);
                    } catch (Exception e) {
                        result.error("errCert", "certificate pinning failed", e.toString());
                    }
                    break;
                case ("setReplicatorContinuous"):
                    Boolean _continuous = call.arguments();
                    try {
                        result.success(mCBManager.setReplicatorContinuous(_continuous));
                    } catch (Exception e) {
                        result.error("errContinuous", "unable to set replication to continuous", e.toString());
                    }
                    break;
                case ("initReplicator"):
                    mCBManager.initReplicator();
                    result.success("");
                    break;
                case ("startReplicator"):
                    mCBManager.startReplicator();
                    result.success("");
                    break;
                case ("stopReplicator"):
                    mCBManager.stopReplicator();
                    result.success("");
                    break;
                case ("closeDatabase"):
                    try {
                        Database database = mCBManager.getDatabase();
                        database.close();
                        result.success(database.getName());
                    } catch (Exception e) {
                        result.error("errInit", "error closing database", e.toString());
                    }
                    break;
                case ("getDocumentCount"):
                    try {
                        result.success(mCBManager.getDocumentCount());
                    } catch (Exception e) {
                        result.error("errGet", "error getting the document count.", e.toString());
                    }
                    break;
                default:
                    result.notImplemented();
            }
        }
    }

    private class JSONCallHandler implements MethodCallHandler {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
            JSONObject queryJson = call.arguments();

            final String queryId;
            try {
                queryId = queryJson.getString("queryId");
            } catch (JSONException e) {
                result.error("errArg", "Query Error: Invalid Arguments", e);
                return;
            }

            Query queryFromJson;
            switch (call.method) {
                case ("execute"):
                    queryFromJson = mCBManager.getQuery(queryId);
                    if (queryFromJson == null) {
                        queryFromJson = new QueryJson(queryJson,mCBManager).toCouchbaseQuery();
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
                    queryFromJson = mCBManager.getQuery(queryId);
                    if (queryFromJson == null) {
                        queryFromJson = new QueryJson(queryJson,mCBManager).toCouchbaseQuery();

                        if (queryFromJson != null) {
                            ListenerToken mListenerToken = queryFromJson.addChangeListener(new QueryChangeListener() {
                                @Override
                                public void changed(QueryChange change) {
                                    HashMap<String,Object> json = new HashMap<String,Object>();
                                    json.put("query",queryId);

                                    if (change.getResults() != null) {
                                        json.put("results",QueryJson.resultsToJson(change.getResults()));
                                    }

                                    if (change.getError() != null) {
                                        json.put("error",change.getError().getLocalizedMessage());
                                    }

                                    final EventChannel.EventSink eventSink = mQueryEventListener.mEventSink;
                                    if (eventSink != null) {
                                        eventSink.success(json);
                                    }
                                }
                            });

                            mCBManager.addQuery(queryId, queryFromJson, mListenerToken);
                        }
                    }

                    result.success(queryFromJson != null);

                    break;
                case ("remove"):
                    mCBManager.removeQuery(queryId);
                    result.success(true);
                    break;
                default:
                    result.notImplemented();
            }
        }
    }
}
