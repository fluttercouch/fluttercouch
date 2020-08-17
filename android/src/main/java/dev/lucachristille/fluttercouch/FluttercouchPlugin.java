package dev.lucachristille.fluttercouch;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.couchbase.lite.CouchbaseLite;
import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.DatabaseConfiguration;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.Query;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FluttercouchPlugin
 */
public class FluttercouchPlugin implements FlutterPlugin {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private MethodChannel methodChannel;
    private MethodChannel jsonChannel;
    private EventChannel eventsChannel;
    private EventsHandler eventsHandler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        CouchbaseLite.init(flutterPluginBinding.getApplicationContext());

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "dev.lucachristille.fluttercouch/methodChannel");
        methodChannel.setMethodCallHandler(new FluttercouchMethodCallHandler());

        jsonChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "dev.lucachristille.fluttercouch/jsonChannel", JSONMethodCodec.INSTANCE);
        jsonChannel.setMethodCallHandler(new JSONCallHandler());

        eventsChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "dev.lucachristille.fluttercouch/eventsChannel");
        eventsHandler = new EventsHandler();
        eventsChannel.setStreamHandler(eventsHandler);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        jsonChannel.setMethodCallHandler(null);
        eventsChannel.setStreamHandler(null);
    }

    private class FluttercouchMethodCallHandler implements MethodCallHandler {

        private CBManager mCBManager;

        FluttercouchMethodCallHandler() {
            this.mCBManager = CBManager.getInstance();
        }

        @Override
        public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
            String _dbName;
            if (call.hasArgument("dbName")) {
                _dbName = call.argument("dbName");
            } else {
                _dbName = mCBManager.getDatabase().getName();
            }

            switch (call.method) {
                case ("initDatabaseWithName"):
                    String _directory = null;
                    if (call.hasArgument("directory")) {
                        _directory = call.argument("directory");
                    }
                    try {
                        DatabaseConfiguration dbConfig = new DatabaseConfiguration();
                        if (_directory != null) {
                            dbConfig.setDirectory(_directory);
                        }
                        mCBManager.initDatabaseWithName(_dbName, dbConfig);
                        HashMap<String, String> response = new HashMap<>();
                        response.put("dbName", _dbName);
                        response.put("directory", dbConfig.getDirectory());
                        result.success(response);
                    } catch (Exception e) {
                        result.error("errInit", "error initializing database with name " + _dbName, e.toString());
                    }
                    break;
                case ("compactDatabase"):
                    try {
                        mCBManager.compactDatabaseWithName(_dbName);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errCompact", "error compacting database with name " + _dbName, e.toString());
                    }
                    break;
                case ("closeDatabaseWithName"):
                    try {
                        mCBManager.closeDatabaseWithName(_dbName);
                        result.success(_dbName);
                    } catch (Exception e) {
                        result.error("errClose", "error closing database with name " + _dbName, e.toString());
                    }
                    break;
                case ("deleteDatabaseWithName"):
                    try {
                        mCBManager.deleteDatabaseWithName(_dbName);
                        result.success(null);
                    } catch (Exception e) {
                        result.error("errDelete", "error deleting database with name " + _dbName, e.toString());
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
                    String _id = call.argument("id");
                    try {
                        result.success(mCBManager.getDocumentWithId(_id));
                    } catch (CouchbaseLiteException e) {
                        result.error("errGet", "error getting the document with id: " + _id, e.toString());
                    }
                    break;
                case ("deleteDocument"):
                    _id = call.argument("id");
                    try {
                        mCBManager.deleteDocument(_id, _dbName);
                        result.success(null);
                    } catch (CouchbaseLiteException e) {
                        result.error("errDelDoc", "error deleting the document with id: " + _id, e.toString());
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
                        result.success(mCBManager.getDatabase(_dbName).getCount());
                    } catch (Exception e) {
                        result.error("errGet", "error getting the document count.", e.toString());
                    }
                    break;
                case("registerDocumentChangeListener"):
                    String id = call.argument("id");
                    String token = call.argument("token");
                    try {
                        mCBManager.addDocumentChangeListener(_dbName, id, token, eventsHandler);
                        result.success(token);
                    } catch (Exception e) {
                        result.error("errDocList", "error adding document change listener to document " + id + " on db " + _dbName, e.toString());
                    }
                default:
                    result.notImplemented();
            }
        }
    }

    private static class JSONCallHandler implements MethodCallHandler {

        private CBManager mCBManager;

        JSONCallHandler() {
            this.mCBManager = CBManager.getInstance();
        }

        @Override
        public void onMethodCall(MethodCall call, @NonNull final Result result) {
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
                        queryFromJson = new QueryJson(json, mCBManager).toCouchbaseQuery();
                    }

                    if (queryFromJson == null) {
                        result.error("errQuery", "Error generating query", null);
                        return;
                    }

                    final Query query = queryFromJson;
                    AsyncTask.THREAD_POOL_EXECUTOR.execute(() -> {
                        try {
                            final List<Map<String, Object>> resultsList = QueryJson.resultsToJson(query.execute());
                            new Handler(Looper.getMainLooper()).post(() -> result.success(resultsList));
                        } catch (final CouchbaseLiteException e) {
                            new Handler(Looper.getMainLooper()).post(() -> result.error("errQuery", "Error executing query", e.toString()));
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
                        queryFromJson = new QueryJson(json, mCBManager).toCouchbaseQuery();

                        if (queryFromJson != null) {
                            ListenerToken mListenerToken = queryFromJson.addChangeListener(AsyncTask.THREAD_POOL_EXECUTOR, change -> {
                                final HashMap<String, Object> json1 = new HashMap<>();
                                json1.put("query", id);

                                json1.put("results", QueryJson.resultsToJson(change.getResults()));

                                if (change.getError() != null) {
                                    json1.put("error", change.getError().getLocalizedMessage());
                                }

                                new Handler(Looper.getMainLooper()).post(() -> {
                                    //final EventChannel.EventSink eventSink = mQueryEventListener.mEventSink;
                                    //if (eventSink != null) {
                                    //    eventSink.success(json);
                                    //}
                                });

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