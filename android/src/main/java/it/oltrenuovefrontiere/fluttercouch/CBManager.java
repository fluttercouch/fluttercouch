package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.*;

import java.util.Map;

public class CBManager {
    private static final CBManager mInstance = new CBManager();
    private Database _database;

    private CBManager() {
    }

    public static CBManager getInstance() {
        return mInstance;
    }

    public String saveDocument(Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_map);
        _database.save(mutableDoc);
        String returnedId = mutableDoc.getId();
        return returnedId;
    }

    public String saveDocumentWithId(String _id, Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_id, _map);
        _database.save(mutableDoc);
        String returnedId = mutableDoc.getId();
        return returnedId;
    }

    public Map<String, Object> getDocumentWithId(String _id) throws CouchbaseLiteException {
        return _database.getDocument(_id).toMap();
    }

    public void initDatabaseWithName(String _name) throws Exception, CouchbaseLiteException {
        DatabaseConfiguration config = new DatabaseConfiguration(FluttercouchPlugin.getContextFromReflection());
        _database = new Database(_name, config);
    }
}
