package com.cohenadair.anglerslog;

import android.app.Application;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

/**
 * The AnglersLogApplication class is used for startup and teardown code execution.
 * @author Cohen Adair
 */
public class AnglersLogApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        Logbook.init(getApplicationContext());
        LogbookPreferences.init(getApplicationContext());
        PhotoUtils.init(getApplicationContext());
        PhotoUtils.cleanPhotosAsync();
    }

}
