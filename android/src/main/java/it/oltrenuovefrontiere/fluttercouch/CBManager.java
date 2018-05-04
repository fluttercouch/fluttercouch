package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;

public class CBManager {
    private static final CBManager mInstance = new CBManager();
    private Database mDatabase;
    private ReplicatorConfiguration mReplConfig;
    private Replicator mReplicator;

    private CBManager() {
    }

    public static CBManager getInstance() {
        return mInstance;
    }

    public String saveDocument(Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_map);
        mDatabase.save(mutableDoc);
        String returnedId = mutableDoc.getId();
        return returnedId;
    }

    public String saveDocumentWithId(String _id, Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_id, _map);
        mDatabase.save(mutableDoc);
        String returnedId = mutableDoc.getId();
        return returnedId;
    }

    public Map<String, Object> getDocumentWithId(String _id) throws CouchbaseLiteException {
        return mDatabase.getDocument(_id).toMap();
    }

    public void initDatabaseWithName(String _name) throws Exception, CouchbaseLiteException {
        DatabaseConfiguration config = new DatabaseConfiguration(FluttercouchPlugin.getContextFromReflection());
        mDatabase = new Database(_name, config);
    }

    public String setReplicatorEndpoint(String _endpoint) throws URISyntaxException {
        Endpoint targetEndpoint = new URLEndpoint(new URI(_endpoint));
        mReplConfig = new ReplicatorConfiguration(mDatabase, targetEndpoint);
        return mReplConfig.getTarget().toString();
    }

    public String setReplicatorType (String _type) throws CouchbaseLiteException {
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

    public void startReplicator() {
        mReplicator = new Replicator(mReplConfig);
        mReplicator.start();
    }

    public void stopReplicator() {
        mReplicator.stop();
        mReplicator = null;
    }
}
