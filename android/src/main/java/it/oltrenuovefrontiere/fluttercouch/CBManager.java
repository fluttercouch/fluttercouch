package it.oltrenuovefrontiere.fluttercouch;

import android.content.res.AssetManager;

import com.couchbase.lite.BasicAuthenticator;
import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.DatabaseConfiguration;
import com.couchbase.lite.Document;
import com.couchbase.lite.EncryptionKey;
import com.couchbase.lite.Endpoint;
import com.couchbase.lite.LogFileConfiguration;
import com.couchbase.lite.LogLevel;
import com.couchbase.lite.MutableDocument;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.ReplicatorConfiguration;
import com.couchbase.lite.SessionAuthenticator;
import com.couchbase.lite.URLEndpoint;
import com.couchbase.lite.Query;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;

class CBManager {
    public static final CBManager instance = new CBManager();
    private HashMap<String, Database> mDatabase = new HashMap<>();
    private HashMap<String, Query> mQueries = new HashMap<>();
    private ReplicatorConfiguration mReplConfig;
    private Replicator mReplicator;
    private String defaultDatabase = "defaultDatabase";
    private DatabaseConfiguration mDBConfig = new DatabaseConfiguration(FluttercouchPlugin.registrar.context());

    private CBManager() {
        final File path = FluttercouchPlugin.registrar.context().getCacheDir();
        Database.log.getFile().setConfig(new LogFileConfiguration(path.toString()));
        Database.log.getFile().setLevel(LogLevel.INFO);
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

    public Map<String, Object> getDocumentWithId(String _id) throws CouchbaseLiteException {
        Database defaultDb = getDatabase();
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
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
    private void setEncryptionKey(String password) {
        EncryptionKey key = new EncryptionKey(password);
        mDBConfig.setEncryptionKey(key);
    }

    public void initDatabaseWithName(String _name) throws CouchbaseLiteException {
        if (!mDatabase.containsKey(_name)) {
            defaultDatabase = _name;
            mDatabase.put(_name, new Database(_name, mDBConfig));
        }
    }

    public void deleteDatabaseWithName(String _name) throws CouchbaseLiteException {
        Database.delete(_name,new File(mDBConfig.getDirectory()));
    }

    public void closeDatabaseWithName(String _name) throws CouchbaseLiteException {
        Database _db = mDatabase.remove(_name);
        if (_db != null) {
            _db.close();
        }
    }

    public String setReplicatorEndpoint(String _endpoint) throws URISyntaxException {
        Endpoint targetEndpoint = new URLEndpoint(new URI(_endpoint));
        mReplConfig = new ReplicatorConfiguration(mDatabase.get(defaultDatabase), targetEndpoint);
        return mReplConfig.getTarget().toString();
    }

    public String setReplicatorType(String _type) throws CouchbaseLiteException {
        ReplicatorConfiguration.ReplicatorType settedType = ReplicatorConfiguration.ReplicatorType.PULL;
        if (_type.equals("PUSH")) {
            settedType = ReplicatorConfiguration.ReplicatorType.PUSH;
        } else if (_type.equals("PULL")) {
            settedType = ReplicatorConfiguration.ReplicatorType.PULL;
        } else if (_type.equals("PUSH_AND_PULL")) {
            settedType = ReplicatorConfiguration.ReplicatorType.PUSH_AND_PULL;
        }
        mReplConfig.setReplicatorType(settedType);
        return settedType.toString();
    }

    public String setReplicatorBasicAuthentication(Map<String, String> _auth) throws Exception {
        if (_auth.containsKey("username") && _auth.containsKey("password")) {
            mReplConfig.setAuthenticator(new BasicAuthenticator(_auth.get("username"), _auth.get("password")));
        } else {
            throw new Exception();
        }
        return mReplConfig.getAuthenticator().toString();
    }

    public String setReplicatorSessionAuthentication(String sessionID) throws Exception {
        if (sessionID != null) {
            mReplConfig.setAuthenticator(new SessionAuthenticator(sessionID));
        } else {
            throw new Exception();
        }
        return mReplConfig.getAuthenticator().toString();
    }

    public void setReplicatorPinnedServerCertificate(String assetKey) throws Exception {
        if (assetKey != null) {
            AssetManager assetManager = FluttercouchPlugin.registrar.context().getAssets();
            String fileKey = FluttercouchPlugin.registrar.lookupKeyForAsset(assetKey);

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
        } else {
            throw new Exception();
        }
    }

    public boolean setReplicatorContinuous(boolean _continuous) {
        mReplConfig.setContinuous(_continuous);
        return mReplConfig.isContinuous();
    }

    public void initReplicator() {
        mReplicator = new Replicator(mReplConfig);
    }

    public void startReplicator() {
        mReplicator.start();
    }

    public void stopReplicator() {
        mReplicator.stop();
        mReplicator = null;
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

    public void addQuery(String queryId, Query query) {
        mQueries.put(queryId,query);
    }

    public Query getQuery(String queryId) {
        return mQueries.get(queryId);
    }

    public Query removeQuery(String queryId) {
        return mQueries.remove(queryId);
    }
}
