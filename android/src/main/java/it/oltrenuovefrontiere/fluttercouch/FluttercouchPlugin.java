package it.oltrenuovefrontiere.fluttercouch;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

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
                        result.success(_name);
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
                        mCBManager.setReplicatorEndpoint(_endpoint);
                        result.success(null);
                    } catch (URISyntaxException e) {
                        result.error("errURI", "error setting the replicator endpoint uri to " + _endpoint, e.toString());
                    }
                    break;
                case ("setReplicatorType"):
                    String _type = call.arguments();
                    try {
                        mCBManager.setReplicatorType(_type);
                        result.success(null);
                    } catch (CouchbaseLiteException e) {
                        result.error("errReplType", "error setting replication type to " + _type, e.toString());
                    }
                    break;
                case ("setReplicatorBasicAuthentication"):
                    Map<String, String> _auth = call.arguments();
                    try {
                        mCBManager.setReplicatorBasicAuthentication(_auth);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errAuth", "error setting authentication for replicator", e.toString());
                    }
                    break;
                case ("setReplicatorSessionAuthentication"):
                    String _sessionID = call.arguments();
                    try {
                        mCBManager.setReplicatorSessionAuthentication(_sessionID);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errAuth", "invalid session ID", e.toString());
                    }
                    break;
                case ("setReplicatorPinnedServerCertificate"):
                    String assetKey = call.arguments();
                    try {
                        mCBManager.setReplicatorPinnedServerCertificate(assetKey);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errCert", "certificate pinning failed", e.toString());
                    }
                    break;
                case ("setReplicatorContinuous"):
                    Boolean _continuous = call.arguments();
                    try {
                        mCBManager.setReplicatorContinuous(_continuous);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errContinuous", "unable to set replication to continuous", e.toString());
                    }
                    break;
                case ("initReplicator"):
                    mCBManager.initReplicator();
                    result.success(null);
                    break;
                case ("startReplicator"):
                    mCBManager.startReplicator();
                    result.success(null);
                    break;
                case ("stopReplicator"):
                    mCBManager.stopReplicator();
                    result.success(null);
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
        public void onMethodCall(MethodCall call, final Result result) {
            final JSONObject json = call.arguments();

            final String id;
            Query queryFromJson;
            switch (call.method) {
                case ("executeQuery"):
                    try {
                        id = json.getString("queryId");
                    } catch (JSONException e) {
                        result.error("errArg", "Query Error: Invalid Arguments", e);
                        return;
                    }

                    queryFromJson = mCBManager.getQuery(id);
                    if (queryFromJson == null) {
                        queryFromJson = new QueryJson(json,mCBManager).toCouchbaseQuery();
                    }

                    if (queryFromJson == null) {
                        result.error("errQuery", "Error generating query", null);
                        return;
                    }

                    final Query query = queryFromJson;
                    AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                final List<Map<String,Object>> resultsList = QueryJson.resultsToJson(query.execute());
                                new Handler(Looper.getMainLooper()).post(new Runnable() {
                                    @Override
                                    public void run() {
                                        result.success(resultsList);
                                    }
                                });
                            } catch (final CouchbaseLiteException e) {
                                new Handler(Looper.getMainLooper()).post(new Runnable() {
                                    @Override
                                    public void run() {
                                        result.error("errQuery", "Error executing query", e.toString());
                                    }
                                });
                            }
                        }
                    });
                    break;
                case ("storeQuery"):
                    try {
                        id = json.getString("queryId");
                    } catch (JSONException e) {
                        result.error("errArg", "Query Error: Invalid Arguments", e);
                        return;
                    }

                    queryFromJson = mCBManager.getQuery(id);
                    if (queryFromJson == null) {
                        queryFromJson = new QueryJson(json,mCBManager).toCouchbaseQuery();

                        if (queryFromJson != null) {
                            ListenerToken mListenerToken = queryFromJson.addChangeListener(AsyncTask.THREAD_POOL_EXECUTOR, new QueryChangeListener() {
                                @Override
                                public void changed(QueryChange change) {
                                    final HashMap<String,Object> json = new HashMap<String,Object>();
                                    json.put("query",id);

                                    if (change.getResults() != null) {
                                        json.put("results",QueryJson.resultsToJson(change.getResults()));
                                    }

                                    if (change.getError() != null) {
                                        json.put("error",change.getError().getLocalizedMessage());
                                    }

                                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                                        @Override
                                        public void run() {
                                            final EventChannel.EventSink eventSink = mQueryEventListener.mEventSink;
                                            if (eventSink != null) {
                                                eventSink.success(json);
                                            }
                                        }
                                    });

                                }
                            });

                            mCBManager.addQuery(id, queryFromJson, mListenerToken);
                        }
                    }

                    result.success(queryFromJson != null);

                    break;
                case ("removeQuery"):
                    try {
                        id = json.getString("queryId");
                    } catch (JSONException e) {
                        result.error("errArg", "Query Error: Invalid Arguments", e);
                        return;
                    }

                    mCBManager.removeQuery(id);
                    result.success(true);
                    break;
                default:
                    result.notImplemented();
            }
        }
    }
}
