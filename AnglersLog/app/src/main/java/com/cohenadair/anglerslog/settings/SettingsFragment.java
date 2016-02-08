package com.cohenadair.anglerslog.settings;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.preference.ListPreference;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.backup.ImportFragment;
import com.cohenadair.anglerslog.model.Importer;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * The SettingsFragment handles all user preferences.
 * Created by Cohen Adair on 2016-02-02.
 */
public class SettingsFragment extends PreferenceFragmentCompat {

    private static final String TAG = "SettingsFragment";

    private static final int REQUEST_IMPORT = 0;

    private Uri mImportUri;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.preferences);

        initUnits();
        initImport();
        initExport();
        initReset();
        initAbout();
    }

    @Override
    public void onCreatePreferences(Bundle bundle, String s) {

    }

    @Override
    public void onResume() {
        super.onResume();
        showImportDialog();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != Activity.RESULT_OK)
            return;

        if (requestCode == REQUEST_IMPORT) {
            mImportUri = data.getData();
            return;
        }

        super.onActivityResult(requestCode, resultCode, data);
    }

    private void updateUnits(ListPreference units, int index) {
        String[] unitStrings = getResources().getStringArray(R.array.pref_unitTypes_entries);
        units.setSummary(unitStrings[(index == -1) ? LogbookPreferences.getUnits() : index]);
    }

    private void updateUnits(ListPreference units) {
        updateUnits(units, -1);
    }

    private void initUnits() {
        final ListPreference units = (ListPreference)findPreference(getResources().getString(R.string.pref_units));
        units.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                updateUnits(units, Integer.parseInt((String)newValue));
                return true;
            }
        });

        updateUnits(units);
    }

    /**
     * Uses Intent.ACTION_OPEN_DOCUMENT which requires Android KitKat (API Level 19).
     */
    private void initImport() {
        Preference importPref = findPreference(getResources().getString(R.string.pref_import));
        importPref.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("application/x-zip");

                startActivityForResult(intent, REQUEST_IMPORT);
                return true;
            }
        });
    }

    private void initExport() {
        Preference export = findPreference(getResources().getString(R.string.pref_export));
        export.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                return false;
            }
        });
    }

    private void initReset() {
        Preference reset = findPreference(getResources().getString(R.string.pref_reset));
        reset.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                Utils.showResetConfirm(getContext(), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Logbook.reset();
                        Utils.showToast(getContext(), R.string.reset_success);
                    }
                });
                return true;
            }
        });
    }

    private void initAbout() {
        Preference about = findPreference(getResources().getString(R.string.pref_about_group));
        about.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                startActivity(new Intent(getContext(), AboutActivity.class));
                return true;
            }
        });
    }

    private void showImportDialog() {
        if (mImportUri == null)
            return;

        final ImportFragment importFragment = new ImportFragment();
        importFragment.setCallbacks(new ImportFragment.InteractionListener() {
            @Override
            public void onConfirm() {
                Importer.importFromUri(getContext().getContentResolver(), mImportUri, new Importer.OnProgressListener() {
                    @Override
                    public void onFinish() {
                        importFragment.dismiss();
                        Utils.showToast(getContext(), R.string.import_success);
                    }
                });
                mImportUri = null;
            }

            @Override
            public void onCancel() {
                mImportUri = null;
            }
        });
        importFragment.show(getChildFragmentManager(), null);
    }
}
