package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.NavigationManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.UUID;

// TODO rename themes for convention
// TODO hide FAB unless user is at the top of the list (blocks rating star)
// TODO create custom thumbnail crop activity
// TODO update all files' documentation

public class MainActivity extends LayoutSpecActivity {

    private NavigationManager mNavigationManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_layout);

        // needed so the navigation view extends above and on top of the app bar
        Toolbar toolbar = (Toolbar)findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mNavigationManager = new NavigationManager(this);
        mNavigationManager.setUp();

        // needs to be called after MainActivity's initialization code
        // update the current layout
        updateLayoutSpec();

        // keep layout on orientation change
        if (savedInstanceState == null)
            showFragment();

        LogbookPreferences.setIsRootTwoPane(isTwoPane());
    }

    /**
     * Needs to be implemented for children to receive onActivityResult calls.
     */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == android.R.id.home) {
            mNavigationManager.onClickUpButton();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void updateLayoutSpec() {
        setLayoutSpec(LayoutSpecManager.layoutSpec(this, mNavigationManager.getCurrentLayoutId()));
        mNavigationManager.updateTitle();
    }

    public void showFragment() {
        if (getMasterFragment() == null)
            return;

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

        // add left panel
        transaction.replace(R.id.master_container, getMasterFragment(), getMasterTag());

        boolean hasRightPanel = isTwoPane() && (getDetailFragment() != null);

        // add the right panel if needed
        if (hasRightPanel)
            transaction.replace(R.id.detail_container, getDetailFragment(), getDetailTag());

        // hide/show right panel if needed
        LinearLayout detailContainer = (LinearLayout)findViewById(R.id.detail_container);
        Utils.toggleVisibility(detailContainer, hasRightPanel);

        // commit changes
        transaction.commit();
    }

    @Override
    public OnClickInterface getOnMyListFragmentItemClick() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                onMyListItemSelected(id);
            }
        };
    }

    /**
     * Either show the detail fragment or update if it's already shown.
     */
    public void onMyListItemSelected(UUID id) {
        setSelectionId(id);

        DetailFragment detailFragment =
                (DetailFragment)getSupportFragmentManager().findFragmentByTag(getDetailTag());

        if (isTwoPane() && detailFragment != null)
            // update the right panel detail fragment
            detailFragment.update(id);
        else {
            // show the detail fragment
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, getDetailFragment())
                    .addToBackStack(null)
                    .commit();

            mNavigationManager.setActionBarTitle("");
        }
    }

    @Override
    public void goBack() {
        mNavigationManager.goBack();
    }

    //region Navigation
    @Override
    public void onBackPressed() {
        if (mNavigationManager.canGoBack())
            mNavigationManager.onBackPressed();
        else
            super.onBackPressed();
    }

    @Override
    public void goToListManagerView() {
        if (isTwoPane()) {
            // show as popup dialog
            getManageFragment().show(getSupportFragmentManager(), "dialog");
        } else {
            // show normally
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, getManageFragment())
                    .addToBackStack(null)
                    .commit();

            mNavigationManager.setActionBarTitle(getViewTitle());
        }
    }
    //endregion
}
