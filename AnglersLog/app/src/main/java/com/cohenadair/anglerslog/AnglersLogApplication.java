package com.cohenadair.anglerslog;

import android.app.Application;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;

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

        // initialize some dummy catches
        if (Logbook.getInstance().catchCount() <= 0)
            for (int i = 0; i < 24; i++) {
                Calendar calendar = Calendar.getInstance();
                calendar.set(Calendar.MONTH, i % 12);
                Date aDate = calendar.getTime();

                Catch aCatch = new Catch(aDate);
                aCatch.setSpecies(new Species("Species " + i));

                Logbook.getInstance().addCatch(aCatch);
            }

        // initialize some dummy trips
        if (Logbook.getInstance().tripCount() <= 0)
            for (int i = 0; i < 10; i++)
                Logbook.getInstance().addTrip(new Trip("Trip " + i));

        // initialize some dummy species
        Logbook logbook = Logbook.getInstance();

        if (logbook.speciesCount() <= 0) {
            logbook.addSpecies(new Species("Smallmouth Bass"));
            logbook.addSpecies(new Species("Largemouth Bass"));
            logbook.addSpecies(new Species("Walleye"));
            logbook.addSpecies(new Species("Steelhead"));
            logbook.addSpecies(new Species("Atlantic Salmon"));
        }
    }

}
