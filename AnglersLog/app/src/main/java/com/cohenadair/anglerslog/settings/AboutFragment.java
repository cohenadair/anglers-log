package com.cohenadair.anglerslog.settings;

import android.os.Bundle;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.Utils;
import com.google.android.gms.common.GoogleApiAvailability;

/**
 * The SettingsFragment handles all user preferences.
 * Created by Cohen Adair on 2016-02-02.
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

    private void initGoogleMapsTerms() {
        Preference mapsTerms = findPreference(getResources().getString(R.string.pref_google_maps_terms));
        final String licence = GoogleApiAvailability.getInstance().getOpenSourceSoftwareLicenseInfo(getContext());

        if (licence == null)
            mapsTerms.setVisible(false);
        else
            mapsTerms.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
                @Override
                public boolean onPreferenceClick(Preference preference) {
                    Utils.showAlert(getContext(), R.string.google_maps_terms_title, licence);
                    return true;
                }
            });
    }

    private void initIcons8Terms() {
        Preference iconsTerms = findPreference(getResources().getString(R.string.pref_icons8_terms));
        iconsTerms.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                Utils.showAlert(getContext(), getChildFragmentManager(), R.string.icons8_terms_title, R.string.icons8_terms);
                return true;
            }
        });
    }
}
