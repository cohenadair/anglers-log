package com.cohenadair.anglerslog.settings;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.google.android.gms.common.GoogleApiAvailability;

/**
 * The SettingsFragment handles all user preferences.
 * @author Cohen Adair
 */
public class AboutFragment extends PreferenceFragmentCompat {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.about_preferences);

        initGoogleMapsTerms();
        initIcons8Terms();
    }

    @Override
    public void onCreatePreferences(Bundle bundle, String s) {

    }

    @Override
    public void onResume() {
        super.onResume();

        // hide list separators
        setDivider(new ColorDrawable(Color.TRANSPARENT));
        setDividerHeight(0);
    }

    private void initGoogleMapsTerms() {
        Preference mapsTerms = findPreference(getResources().getString(R.string.pref_google_maps_terms));
        final String licence = GoogleApiAvailability.getInstance().getOpenSourceSoftwareLicenseInfo(getContext());

        if (licence == null)
            mapsTerms.setVisible(false);
        else
            mapsTerms.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
                @Override
                public boolean onPreferenceClick(Preference preference) {
                    AlertUtils.show(getContext(), R.string.google_maps_terms_title, licence);
                    return true;
                }
            });
    }

    private void initIcons8Terms() {
        Preference iconsTerms = findPreference(getResources().getString(R.string.pref_icons8_terms));
        iconsTerms.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                AlertUtils.show(getContext(), getChildFragmentManager(), R.string.icons8_terms_title, R.string.icons8_terms);
                return true;
            }
        });
    }
}
