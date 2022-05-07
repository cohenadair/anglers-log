package com.cohenadair.mobile.channels;

import android.app.Activity;
import android.os.Environment;
import android.os.Handler;

import androidx.annotation.NonNull;

import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.backup.JsonExporter;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MigrationChannel {
    private static final String CHANNEL_NAME = "com.cohenadair.anglerslog/migration";
    private static final String EXPORT_NAME = "legacyJson";

    public static void create(@NonNull FlutterEngine flutterEngine, @NonNull Activity activity) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals(EXPORT_NAME)) {
                        new Handler().post(() -> legacyJson(result, activity));
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private static void legacyJson(MethodChannel.Result result, Activity activity) {
        final Map<String, Object> json;
        String oldDbPath = Logbook.init(activity);
        
        if (oldDbPath == null) {
            // If there's no old database file, there's no legacy JSON to return.
            json = null;
        } else {
            String oldImagesPath;
            File oldImagesDir = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
            
            if (oldImagesDir != null) {
                oldImagesPath = oldImagesDir.getPath();
            } else {
                oldImagesPath = null;
            }
            
            try {
                JSONObject legacyJson = JsonExporter.getJson(activity);
                json = new HashMap<>();
                json.put("db", oldDbPath);
                json.put("img", oldImagesPath);
                json.put("json", legacyJson.toString());
            } catch (JSONException e) {
                Logbook.getDatabase().close();
                activity.runOnUiThread(() -> {
                    result.error("E", e.getMessage(), null);
                });
                return;
            }
        }

        if (Logbook.getDatabase() != null) {
            Logbook.getDatabase().close();
        }
        activity.runOnUiThread(() -> result.success(json));
    }
}
