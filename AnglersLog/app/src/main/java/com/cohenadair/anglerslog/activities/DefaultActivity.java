package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;

/**
 * The DefaultActivity class is a normal Activity subclass that includes a toolbar with enabled
 * back navigation. If the activity is shown as a dialog, the toolbar is hidden.
 *
 * ** Note: ** Subclasses must call `setContentView(int layoutResId)` in `onCreate()`, and the
 * layout id used must include a navigation_view.xml layout.
 *
 * Created by Cohen Adair on 2015-12-12.
 */
public abstract class DefaultActivity extends AppCompatActivity {

    public static final String EXTRA_TWO_PANE = "extra_two_pane";

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

    /**
     * Initializes the navigation toolbar. ** This must be called by subclasses. **
     */
    public void initToolbar() {
        Toolbar toolbar = (Toolbar)findViewById(R.id.toolbar);

        if (!isTwoPane()) {
            setSupportActionBar(toolbar);
            ActionBar actionBar = getSupportActionBar();

            if (actionBar != null) {
                actionBar.setDisplayHomeAsUpEnabled(true);
                actionBar.setHomeAsUpIndicator(R.drawable.ic_back);
            }
        } else {
            if (toolbar != null)
                toolbar.setVisibility(View.GONE);
        }
    }

    public boolean isTwoPane() {
        Intent intent = getIntent();
        return intent.getBooleanExtra(EXTRA_TWO_PANE, false);
    }

    public void setActionBarTitle(String title) {
        if (getSupportActionBar() != null)
            getSupportActionBar() .setTitle(title);
    }
}
