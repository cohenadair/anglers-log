package com.cohenadair.anglerslog.utilities;

import android.support.design.widget.NavigationView;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;

/**
 * A wrapper class to manage drawer navigation.
 * Created by Cohen Adair on 2015-09-16.
 */
public class NavigationManager implements FragmentManager.OnBackStackChangedListener {

    private DrawerLayout mDrawerLayout;
    private NavigationView mNavigationView;
    private ActionBar mActionBar;
    private MainActivity mActivity;
    private String mCurrentTitle;

    public NavigationManager(MainActivity activity) {
        mActivity = activity;
        mDrawerLayout = (DrawerLayout)mActivity.findViewById(R.id.main_drawer);
        mNavigationView = (NavigationView)mActivity.findViewById(R.id.navigation_view);
        mActionBar = mActivity.getSupportActionBar();
        mCurrentTitle = mActivity.getResources().getString(R.string.app_name);
    }

    /**
     * Instances of this class must call this method after initialization.
     */
    public void setUp() {
        mNavigationView.setNavigationItemSelectedListener(new NavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem menuItem) {
                onDrawerItemSelected(menuItem);
                return true;
            }
        });

        mActivity.getSupportFragmentManager().addOnBackStackChangedListener(this);

        mActionBar.setDisplayHomeAsUpEnabled(true);
        showMenuButton();
    }

    public void showMenuButton() {
        mActionBar.setHomeAsUpIndicator(R.drawable.ic_menu);
    }

    public void showBackButton() {
        mActionBar.setHomeAsUpIndicator(R.drawable.ic_back);
    }

    public void onClickUpButton() {
        if (canGoBack())
            goBack();
        else
            mDrawerLayout.openDrawer(GravityCompat.START);
    }

    public void restoreActionBar() {
        mActionBar.setDisplayShowTitleEnabled(true);
        mActionBar.setTitle(mCurrentTitle);
    }

    public void setActionBarTitle(String title) {
        mActionBar.setTitle(title);
    }

    public boolean canGoBack() {
        return mActivity.getSupportFragmentManager().getBackStackEntryCount() > 0;
    }

    public void goBack() {
        mActivity.getSupportFragmentManager().popBackStack();
        restoreActionBar();
    }

    public void onBackPressed() {
        goBack();
    }

    @Override
    public void onBackStackChanged() {
        if (canGoBack())
            showBackButton();
        else
            showMenuButton();
    }

    private void onDrawerItemSelected(MenuItem menuItem) {
        FragmentData.setCurrentFragmentId(menuItem.getItemId());
        mActivity.showFragment(null);

        menuItem.setChecked(true);
        mDrawerLayout.closeDrawers();
    }

}
