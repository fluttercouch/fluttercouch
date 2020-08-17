package dev.lucachristille.fluttercouch;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.ReplicatorChange;
import com.couchbase.lite.ReplicatorChangeListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class EventsHandler implements EventChannel.StreamHandler {
    private EventChannel.EventSink mEventSink;

    /*
     * IMPLEMENTATION OF EVENTCHANNEL.STREAMHANDLER
     */

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        mEventSink = null;
    }

    public void success(FluttercouchEvent event) {
        mEventSink.success(event);
    }

    public void error(String errorCode, String errorMessage, Object errorDetails) {
        mEventSink.error(errorCode, errorMessage, errorDetails);
    }
}

