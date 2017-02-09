package com.cohenadair.anglerslog;

import android.app.Application;
import android.content.Context;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.crashlytics.android.Crashlytics;
import com.instabug.library.IBGInvocationEvent;
import com.instabug.library.Instabug;

import io.fabric.sdk.android.Fabric;

/**
 * The AnglersLogApplication class is used for startup and teardown code execution.
 * @author Cohen Adair
 */
public class AnglersLogApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        if (!BuildConfig.DEBUG) {
            Fabric.with(this, new Crashlytics());
        }

        new Instabug
                .Builder(this, "189b6d0684c10aa4f6426bc9c3665a7c")
                .setInvocationEvent(IBGInvocationEvent.IBGInvocationEventFloatingButton)
                .build();

        Context context = getApplicationContext();

        Logbook.init(context);
        PhotoUtils.init(context);
        PhotoUtils.cleanPhotosAsync(context);
        PhotoUtils.convertAllPngToJpg(context);

        // needs to be called after initializing

        Logbook.setDefaults(context);
        Logbook.cleanup(context);
        Logbook.updatePreferences(context);
    }

}
