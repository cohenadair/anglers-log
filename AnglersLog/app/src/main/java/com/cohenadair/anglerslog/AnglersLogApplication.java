package com.cohenadair.anglerslog;

import android.app.Application;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

import java.util.Calendar;
import java.util.Date;

/**
 * The AnglersLogApplication class is used for startup and teardown code execution.
 * @author Cohen Adair
 */
public class AnglersLogApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        Logbook.setContext(getApplicationContext());

        // initialize some dummy catches
        if (Logbook.catchCount() <= 0)
            for (int i = 0; i < 24; i++) {
                Calendar calendar = Calendar.getInstance();
                calendar.set(Calendar.MONTH, i % 12);
                Date aDate = calendar.getTime();

                Catch aCatch = new Catch(aDate);
                aCatch.setSpecies(new Species("Species " + i));

                Logbook.addCatch(aCatch);
            }

        // initialize some dummy trips
        if (Logbook.tripCount() <= 0)
            for (int i = 0; i < 10; i++)
                Logbook.addTrip(new Trip("Trip " + i));

        // initialize some dummy species
        if (Logbook.speciesCount() <= 0) {
            Logbook.addSpecies(new Species("Smallmouth Bass"));
            Logbook.addSpecies(new Species("Largemouth Bass"));
            Logbook.addSpecies(new Species("Walleye"));
            Logbook.addSpecies(new Species("Steelhead"));
            Logbook.addSpecies(new Species("Atlantic Salmon"));
        }

        PhotoUtils.cleanPhotosAsync(getApplicationContext());
    }

}
