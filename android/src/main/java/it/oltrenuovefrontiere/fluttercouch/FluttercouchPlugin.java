package it.oltrenuovefrontiere.fluttercouch;

import android.app.Application;
import android.content.Context;

import com.couchbase.lite.CouchbaseLiteException;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import it.oltrenuovefrontiere.fluttercouch.CBManager;

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

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case("getPlatformVersion"):
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case("initDatabaseWithName"):
                String _name = call.arguments();
                try {
                    mCbManager.initDatabaseWithName(_name);
                    result.success(_name);
                } catch (Exception e) {
                    e.printStackTrace();
                    result.error("errInit", "error initializing database", e.toString());
                }
            case("saveDocument"):
                Map<String, Object> _document = call.arguments();
                try {
                    String returnedId = mCbManager.saveDocument(_document);
                    result.success(returnedId);
                } catch (CouchbaseLiteException e) {
                    e.printStackTrace();
                    result.error("errSave", "error saving the document", e.toString());
                }
                break;
            case("saveDocumentWithId"):
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
            case("getDocumentWithId"):
                String _id = call.arguments();
                try {
                    Map<String, Object> _map = mCbManager.getDocumentWithId(_id);
                    result.success(_map);
                } catch (CouchbaseLiteException e) {
                    e.printStackTrace();
                    result.error("errGet", "error getting the document with id: " + _id, e.toString());
                }
                break;
            default:
                result.notImplemented();
        }
    }

    /**
     * Get ApplicationContext through reflection for dabatase initialization.
     * @return Context
     * @throws Exception
     */

    public static Context getContextFromReflection() throws Exception {
        Application _application = (Application) Class.forName("android.app.ActivityThread").getMethod("currentApplication").invoke(null, (Object[]) null);
        return _application.getApplicationContext();
    }
}
