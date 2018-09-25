package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.ReplicatorChange;
import com.couchbase.lite.ReplicatorChangeListener;

import io.flutter.plugin.common.EventChannel;

public class ReplicationEventListener implements EventChannel.StreamHandler, ReplicatorChangeListener {

    private CBManager mCBmanager;
    private ListenerToken mListenerToken;
    private EventChannel.EventSink mEventSink;

    ReplicationEventListener(CBManager _cbManager) {
        this.mCBmanager = _cbManager;
    }

    /*
     * IMPLEMENTATION OF EVENTCHANNEL.STREAMHANDLER
     */

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
        mListenerToken = mCBmanager.getReplicator().addChangeListener(this);
    }

    @Override
    public void onCancel(Object o) {
        mCBmanager.getReplicator().removeChangeListener(mListenerToken);
        mEventSink = null;
    }

    /*
     *  IMPLEMENTATION OF REPLICATORCHANGELISTENER INTERFACE
     */

    @Override
    public void changed(ReplicatorChange change) {
        CouchbaseLiteException error = change.getStatus().getError();
        if (error != null) {
            mEventSink.error("CouchbaseLiteException", "Error during replication", error.getCode());
        } else {
            switch (change.getStatus().getActivityLevel()) {
                case BUSY:
                    mEventSink.success("BUSY");
                    break;
                case IDLE:
                    mEventSink.success("IDLE");
                    break;
                case OFFLINE:
                    mEventSink.success("OFFLINE");
                    break;
                case STOPPED:
                    mEventSink.success("STOPPED");
                    break;
                case CONNECTING:
                    mEventSink.success("CONNECTING");
                    break;
            }
        }
    }
}
