package com.cohenadair.anglerslog.settings;

import android.os.Bundle;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DefaultActivity;

/**
 * The AboutActivity is a temporary solution to the issues surrounding the v7 support library for
 * {@link android.support.v7.preference.Preference}s. Sub-screens do not work and need to be
 * handled by the programmer.
 *
 * @author Cohen Adair
 */
public class AboutActivity extends DefaultActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_default);

        initToolbar();
        setActionBarTitle(getResources().getString(R.string.about_setting));

        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.container, new AboutFragment())
                .commit();
    }
}
