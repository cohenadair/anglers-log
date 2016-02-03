package com.cohenadair.anglerslog.settings;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.preference.ListPreference;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;

/**
 * The SettingsFragment handles all user preferences.
 * Created by Cohen Adair on 2016-02-02.
 */
public class SettingsFragment extends PreferenceFragmentCompat {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.preferences);

        final ListPreference units = (ListPreference)findPreference(getResources().getString(R.string.pref_units));
        units.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                updateUnits(units, Integer.parseInt((String)newValue));
                return true;
            }
        });

        Preference about = findPreference(getResources().getString(R.string.pref_about_group));
        about.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                startActivity(new Intent(getContext(), AboutActivity.class));
                return true;
            }
        });

        updateUnits(units);
    }

    @Override
    public void onCreatePreferences(Bundle bundle, String s) {

    }

    private void updateUnits(ListPreference units, int index) {
        String[] unitStrings = getResources().getStringArray(R.array.pref_unitTypes_entries);
        units.setSummary(unitStrings[(index == -1) ? LogbookPreferences.getUnits() : index]);
    }

    private void updateUnits(ListPreference units) {
        updateUnits(units, -1);
    }
}
