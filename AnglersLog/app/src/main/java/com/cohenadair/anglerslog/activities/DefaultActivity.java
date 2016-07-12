package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Point;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.GlobalSettingsInterface;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * The DefaultActivity class is a normal Activity subclass that includes a toolbar with enabled
 * back navigation. If the activity is shown as a dialog, the toolbar is hidden.
 *
 * ** Note: ** Subclasses must call `setContentView(int layoutResId)` in `onCreate()`, and the
 * layout id used (if applicable) must include a navigation_view.xml layout.
 *
 * @author Cohen Adair
 */
public abstract class DefaultActivity extends AppCompatActivity implements GlobalSettingsInterface {

    public static final String EXTRA_TWO_PANE = "extra_two_pane";

    private Toolbar mToolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // needs to be done before the calls the super.onCreate() and setContentView()
        if (!isTwoPane()) {
            // show normally if we're not in two-pane mode
            setTheme(R.style.Base_Theme_AnglersLog);
            setTitle("");
        }

        super.onCreate(savedInstanceState);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        // needs to be done here to revert back to MainActivity's state
        // if done using MainActivity as parent in the manifest, MainActivity's fragment is reset
        if (id == android.R.id.home) {
            onBackPressed();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        finish();
    }

    public Toolbar getToolbar() {
        return mToolbar;
    }

    /**
     * Initializes the navigation toolbar. ** This must be called by subclasses. **
     */
    public void initToolbar() {
        mToolbar = (Toolbar)findViewById(R.id.toolbar);

        if (!isTwoPane()) {
            setSupportActionBar(mToolbar);
            ActionBar actionBar = getSupportActionBar();

            if (actionBar != null) {
                actionBar.setDisplayHomeAsUpEnabled(true);
                actionBar.setHomeAsUpIndicator(R.drawable.ic_back);
                actionBar.setHomeActionContentDescription(R.string.back_description);
            }
        } else {
            if (mToolbar != null)
                mToolbar.setVisibility(View.GONE);
        }
    }

    /**
     * If the device is two-pane (and this activity is displayed as a dialog), set the dialog's
     * width to the smaller of the device's width and height.
     */
    public void initDialogWidth() {
        if (!isTwoPane())
            return;

        Point screenSize = Utils.getScreenSize(this);
        getWindow().setLayout((screenSize.x < screenSize.y) ? screenSize.x : screenSize.y, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    @Override
    public boolean isTwoPane() {
        Intent intent = getIntent();
        return intent.getBooleanExtra(EXTRA_TWO_PANE, false);
    }

    public void setActionBarTitle(String title) {
        if (getSupportActionBar() != null)
            getSupportActionBar().setTitle(title);
    }
}
