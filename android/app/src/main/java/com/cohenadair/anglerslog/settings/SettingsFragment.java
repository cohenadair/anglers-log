package com.cohenadair.anglerslog.settings;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.preference.CheckBoxPreference;
import android.support.v7.preference.ListPreference;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.LoadingDialog;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Exporter;
import com.cohenadair.anglerslog.model.backup.Importer;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.Utils;

import java.io.File;

/**
 * The SettingsFragment handles all user preferences.
 * @author Cohen Adair
 */
public class SettingsFragment extends PreferenceFragmentCompat {

    private static final String SUPPORT_EMAIL = "support@anglerslog.ca";

    private static final int REQUEST_IMPORT = 0;
    private static final int REQUEST_EXPORT = 1;

    private Uri mImportUri;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.preferences);
        setHasOptionsMenu(true);

        initUnits();
        initFeedback();
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

        // hide list separators
        setDivider(new ColorDrawable(Color.TRANSPARENT));
        setDividerHeight(0);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != Activity.RESULT_OK)
            return;

        if (requestCode == REQUEST_IMPORT) {
            mImportUri = data.getData();
            return;
        }

        if (requestCode == REQUEST_EXPORT) {
            Utils.showToast(getContext(), R.string.export_success);
            return;
        }

        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
    }

    private void updateUnits(ListPreference units, int index) {
        String[] unitStrings = getResources().getStringArray(R.array.pref_unitTypes_entries);
        units.setSummary(unitStrings[(index == -1) ? LogbookPreferences.getUnits(getContext()) : index]);
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

    private void startBackupActivity(Intent intent, int request) {
        try {
            startActivityForResult(intent, request);
        } catch (ActivityNotFoundException e) {
            // try launching activity again with the mime-type set to all files
            // this is an issue with some devices (known to happen for Galaxy devices)
            try {
                intent.setType("*/*");
                startActivityForResult(intent, request);
            } catch (ActivityNotFoundException e2) {
                e2.printStackTrace();
                AlertUtils.showError(getContext(), R.string.backup_activity_not_found);
            }
        }
    }

    private void initFeedback() {
        Preference importPref = findPreference(getResources().getString(R.string.pref_feedback));
        importPref.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:"));
                intent.putExtra(Intent.EXTRA_EMAIL, new String[] { SUPPORT_EMAIL });
                intent.putExtra(Intent.EXTRA_SUBJECT, "Feedback from Anglers' Log for Android");

                if (intent.resolveActivity(getActivity().getPackageManager()) != null) {
                    startActivity(Intent.createChooser(intent,
                            getResources().getString(R.string.feedback_chooser_title)));
                } else {
                    Utils.showToast(getContext(), R.string.feedback_no_email);
                }

                return true;
            }
        });
    }

    private void initImport() {
        Preference importPref = findPreference(getResources().getString(R.string.pref_import));
        importPref.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType(Utils.MIME_TYPE_ZIP);
                startBackupActivity(intent, REQUEST_IMPORT);
                return true;
            }
        });
    }

    private void initExport() {
        Preference export = findPreference(getResources().getString(R.string.pref_export));
        export.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                showExportDialog();
                return true;
            }
        });
    }

    private void initReset() {
        Preference reset = findPreference(getResources().getString(R.string.pref_reset));
        reset.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                showResetDialog();
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

        final LoadingDialog importFragment =
                LoadingDialog.newInstance(R.string.import_title, R.string.import_name, R.string.import_dialog_message);

        importFragment.setCallbacks(new LoadingDialog.InteractionListener() {
            @Override
            public void onConfirm() {
                Logbook.importFromUri(getContext(), mImportUri, new Importer.OnProgressListener() {
                    @Override
                    public void onFinish() {
                        importFragment.dismiss();
                        Utils.showToast(getContext(), R.string.import_success);
                    }

                    @Override
                    public void onError(String errorMsg) {
                        importFragment.dismiss();
                        Utils.showToast(getContext(), errorMsg);
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

    private void showExportDialog() {
        final LoadingDialog exportFragment =
                LoadingDialog.newInstance(R.string.export_title, R.string.export, R.string.export_dialog_message);

        exportFragment.setCallbacks(new LoadingDialog.InteractionListener() {
            @Override
            public void onConfirm() {
                File zipFile = getContext().getExternalCacheDir();

                Logbook.exportToPath(getContext(), zipFile, new Exporter.OnProgressListener() {
                    @Override
                    public void onFinish(File zipFile) {
                        LogbookPreferences.setBackupFile(getContext(), zipFile.getPath());
                        LogbookPreferences.updateLastBackup(getContext());

                        exportFragment.dismiss();

                        Intent intent = new Intent();
                        intent.setAction(Intent.ACTION_SEND);
                        intent.putExtra(Intent.EXTRA_STREAM,
                                Utils.getFileUri(getContext(), zipFile));
                        intent.setType(Utils.MIME_TYPE_ZIP);

                        startBackupActivity(intent, REQUEST_EXPORT);
                    }

                    @Override
                    public void onError(int errorNo) {
                        exportFragment.dismiss();
                        Utils.showToast(getContext(), getResources().getString(R.string.export_error) + " " + errorNo);
                    }
                });
            }

            @Override
            public void onCancel() {

            }
        });

        exportFragment.show(getChildFragmentManager(), null);
    }

    private void showResetDialog() {
        final LoadingDialog resetDialog =
                LoadingDialog.newInstance(R.string.reset_dialog_title, R.string.reset, R.string.reset_dialog_message);

        resetDialog.setCallbacks(new LoadingDialog.InteractionListener() {
            @Override
            public void onConfirm() {
                Logbook.resetAsync(getContext(), true, new Logbook.OnResetListener() {
                    @Override
                    public void onFinish() {
                        resetDialog.dismiss();
                        Utils.showToast(getContext(), R.string.reset_success);
                    }
                });
            }

            @Override
            public void onCancel() {

            }
        });

        resetDialog.show(getChildFragmentManager(), null);
    }
}
