package dev.lucachristille.fluttercouch;

public class FluttercouchEvent {
    static String DOCUMENT_CHANGE_EVENT = "document_change_event";

    private String eventType;
    private String listenerToken;
    private Object eventPayload;

    FluttercouchEvent(String eventType, String listenerToken, Object eventPayload) {
        this.eventType = eventType;
        this.listenerToken = listenerToken;
        this.eventPayload = eventPayload;
    }
}
