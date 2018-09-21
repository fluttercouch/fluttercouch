package it.oltrenuovefrontiere.fluttercouch;

import org.json.JSONException;
import org.json.JSONTokener;
import org.junit.Test;
import static org.junit.Assert.assertEquals;

import org.json.JSONObject;

public class QueryJsonTest {

    @Test
    public void firstTest() {
        String jsonString = "{\"selectDistinct\":false,\"selectResult\":[[{\"string\":\"all\"}]],\"from\":\"infodiocesi\",\"where\":[{\"property\":\"type\"},{\"equalTo\":[{\"string\":\"SDK\"}]}]}";
        String simplerJsonString = "{\"city\":\"chicago\",\"name\":\"jon doe\",\"age\":\"22\"}";
        try {
            JSONObject json = new JSONObject(simplerJsonString);
            assertEquals("", json);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
