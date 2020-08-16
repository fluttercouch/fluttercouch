package dev.lucachristille.fluttercouch;

import android.content.Context;
import android.content.res.AssetManager;

public interface CBManagerDelegate {
    public String lookupKeyForAsset(String asset);
    public AssetManager getAssets();
    public Context getContext();
}
