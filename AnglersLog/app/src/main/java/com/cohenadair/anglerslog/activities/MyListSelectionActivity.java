package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;

import java.util.UUID;

public class MyListSelectionActivity extends LayoutSpecActivity {

    public static final String EXTRA_SELECTED_ID = "extra_selected_id";
    public static final String EXTRA_LAYOUT_ID = "extra_layout_id";
    public static final String EXTRA_TWO_PANE = "extra_two_pane";

    private ActionBar mActionBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Intent intent = getIntent();
        boolean isTwoPane = intent.getBooleanExtra(EXTRA_TWO_PANE, false);
        int layoutId = intent.getIntExtra(EXTRA_LAYOUT_ID, -1);

        // needs to be done before the calls the super.onCreate() and setContentView()
        // show normally if we're not in two-pane mode
        if (!isTwoPane) {
            setTheme(R.style.Base_Theme_AnglersLog);
            setTitle("");
        }

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_list_selection);

        if (!isTwoPane) {
            Toolbar toolbar = (Toolbar)findViewById(R.id.toolbar);
            setSupportActionBar(toolbar);
            mActionBar = getSupportActionBar();

            if (mActionBar != null) {
                mActionBar.setDisplayHomeAsUpEnabled(true);
                mActionBar.setHomeAsUpIndicator(R.drawable.ic_back);
            }
        }

        setLayoutSpec(LayoutSpecManager.layoutSpec(this, layoutId));

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, getMasterFragment())
                    .commit();
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
    public void onBackPressed() {
        super.onBackPressed();
        setActionBarTitle("");
    }

    @Override
    public OnClickInterface getOnMyListFragmentItemClick() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                finishWithResult(id);
            }
        };
    }

    @Override
    public void goToListManagerView() {
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.container, getManageFragment())
                .addToBackStack(null)
                .commit();

        setActionBarTitle(getViewTitle());
    }

    @Override
    public void goBack() {
        getSupportFragmentManager().popBackStack();
        setActionBarTitle("");
    }

    private void finishWithResult(UUID id) {
        Intent intent = new Intent();
        intent.putExtra(EXTRA_SELECTED_ID, id.toString());
        setResult(RESULT_OK, intent);
        finish();
    }

    private void setActionBarTitle(String title) {
        if (mActionBar != null)
            mActionBar.setTitle(title);
    }
}
