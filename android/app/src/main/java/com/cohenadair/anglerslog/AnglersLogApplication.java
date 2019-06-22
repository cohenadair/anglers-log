package com.cohenadair.anglerslog;

import android.app.Application;
import android.content.Context;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

/**
 * The AnglersLogApplication class is used for startup and teardown code execution.
 * @author Cohen Adair
 */
public class AnglersLogApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

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
