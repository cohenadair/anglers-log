package com.cohenadair.anglerslog;

import android.app.Application;

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

        Logbook.init(getApplicationContext());
        PhotoUtils.init(getApplicationContext());

        /*
        // initialize some dummy species
        if (Logbook.getSpeciesCount() <= 0) {
            Logbook.addSpecies(new Species("Smallmouth Bass"));
            Logbook.addSpecies(new Species("Largemouth Bass"));
            Logbook.addSpecies(new Species("Walleye"));
            Logbook.addSpecies(new Species("Steelhead"));
            Logbook.addSpecies(new Species("Atlantic Salmon"));
        }

        // initialize some dummy catches
        if (Logbook.getCatchCount() <= 0)
            for (int i = 0; i < 12; i++) {
                Calendar calendar = Calendar.getInstance();
                calendar.set(Calendar.MONTH, i % 12);
                Date aDate = calendar.getTime();

                Catch aCatch = new Catch(aDate);
                aCatch.setSpecies(new Species("Species " + i));

                Logbook.addCatch(aCatch);
            }
        */
        PhotoUtils.cleanPhotosAsync();
    }

}
