package com.cohenadair.anglerslog;

import android.app.Application;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.utilities.SortingUtils;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.instabug.library.IBGInvocationEvent;
import com.instabug.library.Instabug;

/**
 * The AnglersLogApplication class is used for startup and teardown code execution.
 * @author Cohen Adair
 */
public class AnglersLogApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        //Fabric.with(this, new Crashlytics());

        new Instabug
                .Builder(this, "189b6d0684c10aa4f6426bc9c3665a7c")
                .setInvocationEvent(IBGInvocationEvent.IBGInvocationEventFloatingButton)
                .build();

        Logbook.init(getApplicationContext());
        LogbookPreferences.init(getApplicationContext());
        SortingUtils.init(getApplicationContext());
        PhotoUtils.init(getApplicationContext());
        PhotoUtils.cleanPhotosAsync();

        // needs to be called after initializing

        Logbook.setDefaults();
        Logbook.cleanup();
        Logbook.updatePreferences();
    }

}
