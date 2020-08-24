package dev.lucachristille.fluttercouch;

import android.content.res.AssetManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.couchbase.lite.BasicAuthenticator;
import com.couchbase.lite.ConcurrencyControl;
import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.DatabaseConfiguration;
import com.couchbase.lite.Document;
import com.couchbase.lite.DocumentChange;
import com.couchbase.lite.DocumentChangeListener;
import com.couchbase.lite.Endpoint;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.MutableDocument;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.ReplicatorConfiguration;
import com.couchbase.lite.SessionAuthenticator;
import com.couchbase.lite.URLEndpoint;
import com.couchbase.lite.Query;

import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

import io.flutter.plugin.common.MethodChannel;

class CBManager {
    private static CBManager instance;

    private HashMap<String, Database> mDatabase = new HashMap<>();
    private HashMap<String, Query> mQueries = new HashMap<>();
    private HashMap<String, ListenerToken> mQueryListenerTokens = new HashMap<>();
    private ReplicatorConfiguration mReplConfig;
    private Replicator mReplicator;
    private String defaultDatabase = "defaultDatabase";
    private HashMap<String, ListenerToken> listenerTokens = new HashMap<>();
    private HashMap<String, ReplicatorConfiguration> mReplicatorConfigurations = new HashMap<>();
    private HashMap<String, Replicator> mReplicators = new HashMap<>();

    private CBManager() {}

    private CBManager(boolean enableLogging) {
        this();

        if (enableLogging) {
            //final File path = mDelegate.getContext().getCacheDir();
            //Database.log.getFile().setConfig(new LogFileConfiguration(path.toString()));
            //Database.log.getFile().setLevel(LogLevel.INFO);
        }
    }

    public Database getDatabase() {
        return mDatabase.get(defaultDatabase);
    }

    public Database getDatabase(String name) {
        if (mDatabase.containsKey(name)) {
            return mDatabase.get(name);
        }
        return null;
    }

    public static CBManager getInstance() {
        if (instance == null) {
            instance = new CBManager();
        }
        return instance;
    }

    public String saveDocument(Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_map);
        mDatabase.get(defaultDatabase).save(mutableDoc);
        return mutableDoc.getId();
    }

    public String saveDocumentWithId(String _id, Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_id, _map);
        mDatabase.get(defaultDatabase).save(mutableDoc);
        return mutableDoc.getId();
    }

    public String saveDocumentWithIdAndConcurrencyControl(String _id, Map<String, Object> _map, String concurrencyControlString) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_id, _map);
        mDatabase.get(defaultDatabase).save(mutableDoc, ConcurrencyControl.valueOf(concurrencyControlString));
        return mutableDoc.getId();
    }

    @SuppressWarnings("unchecked")
    public String saveDocumentWithIdAndCustomerHandler(String _id, Map<String, Object> _map, String conflictHandlerUUID, MethodChannel methodChannel) throws NullPointerException, CouchbaseLiteException {
        final HashMap<String, Object> conflictHandlingResults = new HashMap<>();
        MutableDocument mutableDoc = new MutableDocument(_id, _map);
        mDatabase.get(defaultDatabase).save(mutableDoc, (newDoc, curDoc) -> {
            HashMap<String, Object> arguments = new HashMap<>();
            arguments.put("uuid", conflictHandlerUUID);
            arguments.put("id", newDoc.getId());
            arguments.put("newDoc", newDoc.toMap());
            if (curDoc != null) {
                arguments.put("curDoc", curDoc.toMap());
            } else {
                arguments.put("curDoc", null);
            }
            final FutureTask<Object> ft = new FutureTask<Object>(() -> {}, new Object());
            methodChannel.invokeMethod("invoke_document_conflict_resolver", arguments, new MethodChannel.Result()  {
                @Override
                public void success(@Nullable Object result) {
                    HashMap<String, Object> resultMap = (HashMap<String, Object>) result;
                    conflictHandlingResults.put("returnValue", Objects.requireNonNull(resultMap).get("returnValue"));
                    conflictHandlingResults.put("newDoc", resultMap.get("newDoc"));
                    ft.run();
                }

                @Override
                public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                    conflictHandlingResults.put("returnValue", "exception");
                    ft.run();
                }

                @Override
                public void notImplemented() {
                    conflictHandlingResults.put("returnValue", "notImplemented");
                    ft.run();
                }
            });

            try {
                ft.get();
            } catch (ExecutionException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if (conflictHandlingResults.get("returnValue") == "true") {
                newDoc.setData((HashMap<String, Object>) Objects.requireNonNull(conflictHandlingResults.get("newDoc")));
                return true;
            } else {
                return false;
            }
        });
        return (String) conflictHandlingResults.get("returnValue");
    }

    public Map<String, Object> getDocumentWithId(String _id) {
        Database defaultDb = getDatabase();
        HashMap<String, Object> resultMap = new HashMap<>();
        if (defaultDatabase != null) {
            try {
                Document document = defaultDb.getDocument(_id);
                if (document != null) {
                    resultMap.put("doc", document.toMap());
                    resultMap.put("id", _id);
                } else {
                    resultMap.put("doc", null);
                    resultMap.put("id", _id);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return resultMap;
    }

    // ENCRYPTION IS ONLY COMPATIBLE WITH ENTERPRISE EDITION - NOT SUPPORTING //
    //private void setEncryptionKey(String password) {
    //    EncryptionKey key = new EncryptionKey(password);
    //    mDBConfig.setEncryptionKey(key);
   // }

    public void initDatabaseWithName(String _name, DatabaseConfiguration dbConfig) throws CouchbaseLiteException {
        if (!mDatabase.containsKey(_name)) {
            defaultDatabase = _name;
            mDatabase.put(_name, new Database(_name, dbConfig));
        }
    }

    public void deleteDatabaseWithName(String _name) throws CouchbaseLiteException, NullPointerException {
        Database.delete(_name,new File(mDatabase.get(_name).getConfig().getDirectory()));
    }

    public void compactDatabaseWithName(String _name) throws CouchbaseLiteException, NullPointerException {
        if (!mDatabase.containsKey(_name)) {
            mDatabase.get(_name).compact();
        }
    }

    public void closeDatabaseWithName(String _name) throws CouchbaseLiteException {
        Database _db = mDatabase.remove(_name);
        if (_db != null) {
            _db.close();
        }
    }

    public void deleteDocument(String _id, String _name) throws CouchbaseLiteException {
        Database _db;
        if (_name != null) {
            _db = getDatabase(_name);
        } else {
            _db = getDatabase();
        }
        Document doc = _db.getDocument(_id);
        if (doc != null) {
            _db.delete(doc);
        }
    }

    public void setReplicatorEndpoint(String _endpoint) throws URISyntaxException {
        Endpoint targetEndpoint = new URLEndpoint(new URI(_endpoint));
        mReplConfig = new ReplicatorConfiguration(mDatabase.get(defaultDatabase), targetEndpoint);
    }

    public void setReplicatorType(String _type) {
        ReplicatorConfiguration.ReplicatorType settedType = ReplicatorConfiguration.ReplicatorType.PULL;
        if (_type.equals("PUSH")) {
            settedType = ReplicatorConfiguration.ReplicatorType.PUSH;
        } else if (_type.equals("PULL")) {
            settedType = ReplicatorConfiguration.ReplicatorType.PULL;
        } else if (_type.equals("PUSH_AND_PULL")) {
            settedType = ReplicatorConfiguration.ReplicatorType.PUSH_AND_PULL;
        }
        mReplConfig.setReplicatorType(settedType);
    }

    public void setReplicatorBasicAuthentication(String uuid, String username, String password) {
            Objects.requireNonNull(this.mReplicatorConfigurations.get(uuid)).setAuthenticator(new BasicAuthenticator(username, password));
            this.mReplicatorConfigurations.get(uuid).
    }

    public void setReplicatorSessionAuthentication(String uuid, String sessionID, String cookieName) {
            Objects.requireNonNull(this.mReplicatorConfigurations.get(uuid)).setAuthenticator(new SessionAuthenticator(sessionID, cookieName));
    }

    public void setReplicatorPinnedServerCertificate(String assetKey) throws Exception {
        if (assetKey != null) {
            /*AssetManager assetManager = mDelegate.getAssets();
            String fileKey = mDelegate.lookupKeyForAsset(assetKey);

            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            try (InputStream is = assetManager.open(fileKey)) {
                int nRead;
                byte[] data = new byte[1024];
                while ((nRead = is.read(data, 0, data.length)) != -1) {
                    buffer.write(data, 0, nRead);
                }

                buffer.flush();
            }

            mReplConfig.setPinnedServerCertificate(buffer.toByteArray());
            */
        } else {
            throw new Exception();
        }
    }

    public void setReplicatorContinuous(String uuid, boolean _continuous) {
        Objects.requireNonNull(this.mReplicatorConfigurations.get(uuid)).setContinuous(_continuous);
    }

    public void startReplicator(String uuid) {
        Objects.requireNonNull(this.mReplicators.get(uuid)).start();
    }

    public void stopReplicator(String uuid) {
        Objects.requireNonNull(this.mReplicators.get(uuid)).stop();
    }

    public long getDocumentCount() throws Exception {
        Database defaultDb = getDatabase();
        if (defaultDb != null) {
            return defaultDb.getCount();
        } else {
            throw new Exception();
        }
    }

    public Replicator getReplicator() {
        return mReplicator;
    }

    void addQuery(String queryId, Query query, ListenerToken token) {
        mQueries.put(queryId,query);
        mQueryListenerTokens.put(queryId,token);
    }

    Query getQuery(String queryId) {
        return mQueries.get(queryId);
    }

    Query removeQuery(String queryId) {
        Query query = mQueries.remove(queryId);
        ListenerToken token = mQueryListenerTokens.remove(queryId);
        if (query != null && token != null) {
            query.removeChangeListener(token);
        }

        return query;
    }

    ListenerToken addDocumentChangeListener(String _dbName, String id, String token, EventsHandler eventsHandler) {
        return this.getDatabase(_dbName).addDocumentChangeListener(id, new DocumentChangeListener() {
            @Override
            public void changed(@NonNull DocumentChange change) {
                HashMap<String, String> payload = new HashMap<>();
                payload.put("database", change.getDatabase().getName());
                payload.put("documentID", change.getDocumentID());
                FluttercouchEvent event = new FluttercouchEvent(FluttercouchEvent.DOCUMENT_CHANGE_EVENT, token, payload);
                eventsHandler.success(event);
            }
        });
    }

    void setDocumentExpiration(String _dbName, String id, Date expiration) throws CouchbaseLiteException {
        Database _db = this.getDatabase(_dbName);
        _db.setDocumentExpiration(id, expiration);
    }

    Date getDocumentExpiration(String _dbName, String id) throws CouchbaseLiteException {
        Database _db = this.getDatabase(_dbName);
        return _db.getDocumentExpiration(id);
    }

    void constructReplicatorConfigurationFromDatabaseEndpoint(String uuid, String dbName, @NotNull String endpointType, HashMap<String, String> endpointConfig) throws URISyntaxException {
        Database db = getDatabase(dbName);
        Endpoint endpoint = null;
        if (endpointType.equals("urlEndpoint")) {
            URI uri = new URI(endpointConfig.get("uri"));
            endpoint = new URLEndpoint(uri);
        }
        if (endpoint != null) {
            this.mReplicatorConfigurations.put(uuid, new ReplicatorConfiguration(db, endpoint));
        }
    }

    void constructReplicator(String uuid, String replicatorConfigurationUuid) {
        this.mReplicators.put(uuid, new Replicator(Objects.requireNonNull(this.mReplicatorConfigurations.get(replicatorConfigurationUuid))));
    }
}
