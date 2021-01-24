package com.cohenadair.mobile;

import androidx.annotation.NonNull;

import com.cohenadair.mobile.channels.MigrationChannel;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MigrationChannel.create(flutterEngine, this);
    }
}
