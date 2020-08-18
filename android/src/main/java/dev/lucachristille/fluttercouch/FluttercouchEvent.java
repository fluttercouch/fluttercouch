package dev.lucachristille.fluttercouch;

import java.util.HashMap;

public class FluttercouchEvent {
    static String DOCUMENT_CHANGE_EVENT = "document_change_event";

    private String type;
    private String listenerToken;
    private HashMap<String, String> payload;

    FluttercouchEvent(String type, String listenerToken, HashMap<String, String> payload) {
        this.type = type;
        this.listenerToken = listenerToken;
        this.payload = payload;
    }

    HashMap<String, String> toMap() {
        HashMap<String, String> result = new HashMap<>();
        result.put("type", type);
        result.put("listenerToken", listenerToken);
        result.putAll(payload);
        return result;
    }
}
