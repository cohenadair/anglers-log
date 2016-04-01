package com.cohenadair.anglerslog.ui;

import android.support.test.espresso.contrib.DrawerActions;

import com.cohenadair.anglerslog.R;

/**
 * A collection of useful UI testing methods.
 * @author Cohen Adair
 */
public class TestUtils {

    public static void openDrawer() {
        DrawerActions.openDrawer(R.id.main_drawer);
    }

}
