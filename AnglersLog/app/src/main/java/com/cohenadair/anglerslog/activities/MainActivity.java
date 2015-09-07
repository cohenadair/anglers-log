package com.cohenadair.anglerslog.activities;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.DrawerFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;
import com.cohenadair.anglerslog.utilities.fragment.FragmentUtils;

public class MainActivity extends AppCompatActivity implements
        MyListFragment.OnMyListFragmentInteractionListener,
        ManageFragment.OnManageFragmentInteractionListener,
        DrawerFragment.DrawerFragmentCallbacks,
        android.support.v4.app.FragmentManager.OnBackStackChangedListener
{

    private FragmentInfo mFragmentInfo;
    private DrawerFragment mDrawerFragment;
    private CharSequence mCurrentTitle; // for use in {@link #restoreActionBar()}

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_layout);

        showFragment(savedInstanceState);

        initBackNavigation();
        initDrawerNavigation();

        // adds a small shadow to the bottom of the actionbar
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
            actionBar.setElevation(5);
    }

    @Override
    public void onDrawerItemSelected(int position) {
        // update action bar title
        if (mDrawerFragment != null)
            mCurrentTitle = mDrawerFragment.getNavItems()[position];

        FragmentUtils.setCurrentFragmentId(position);
        showFragment(null);

        Log.d("OnDrawerItemSelected", "Selected position: " + position);
    }

    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayShowTitleEnabled(true);
            actionBar.setTitle(mCurrentTitle);
        }
    }

    public void setActionBarTitle(String title) {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
            actionBar.setTitle(title);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!mDrawerFragment.isDrawerOpen()) {
            // Only show items in the action bar relevant to this screen
            // if the drawer is not showing. Otherwise, let the drawer
            // decide what to show in the action bar.
            getMenuInflater().inflate(R.menu.menu_main, menu);
            restoreActionBar();
            return true;
        }

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == android.R.id.home) {
            handleBackPress();
            // no return because the DrawerFragment's onOptionsItemSelected needs to fire
        }

        return super.onOptionsItemSelected(item);
    }

    private void showFragment(@Nullable Bundle savedInstanceState) {
        mFragmentInfo = FragmentUtils.fragmentInfo(this, FragmentUtils.getCurrentFragmentId());

        // avoid multiple fragments stacked on top of one another
        if (savedInstanceState != null)
            return;

        if (mFragmentInfo != null) {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

            // add left panel
            transaction.replace(R.id.master_container, mFragmentInfo.getFragment(), mFragmentInfo.getTag());

            // add the right panel if needed
            if (isTwoPane())
                transaction.replace(R.id.detail_container, mFragmentInfo.detailFragment(), mFragmentInfo.detailTag());

            // commit changes
            transaction.commit();
        }
    }

    //region MyListFragment.OnListItemSelectedListener interface
    @Override
    public void onItemSelected(int position) {
        FragmentUtils.selectionPos(FragmentUtils.getCurrentFragmentId(), position);

        DetailFragment detailFragment = (DetailFragment)getSupportFragmentManager().findFragmentByTag(mFragmentInfo.detailTag());

        if (isTwoPane())
            detailFragment.update(position);
        else {
            // show the single catch fragment
            detailFragment = (DetailFragment)mFragmentInfo.detailFragment();

            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, detailFragment)
                       .addToBackStack(null)
                       .commit();

            setActionBarTitle("");
        }
    }

    @Override
    public void onClickNewButton(View v) {
        ManageFragment manageFragment = mFragmentInfo.manageFragment();

        if (isTwoPane()) {
            // show as popup
            manageFragment.show(getSupportFragmentManager(), "dialog");
        } else {
            // show normally
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, manageFragment)
                       .addToBackStack(null)
                       .commit();

            setActionBarTitle("New " + mFragmentInfo.getName());
        }
    }
    //endregion

    //region ManageFragment.OnManageFragmentInteractionListener interface
    @Override
    public void onClickCancel(View v) {
        Utils.showToast(this, "Clicked Cancel!");
    }

    @Override
    public void onClickConfirm(View v) {
        Utils.showToast(this, "Clicked Done!");
    }
    //endregion

    //region Navigation
    private void initBackNavigation() {
        if (!isTwoPane())
            getSupportFragmentManager().addOnBackStackChangedListener(this);
    }

    private void handleBackPress() {
        if (!mDrawerFragment.isHamburgerVisible()) {
            getSupportFragmentManager().popBackStack();
            restoreActionBar();
        }
    }

    @Override
    public void onBackPressed() {
        if (canGoBack())
            handleBackPress();
        else
            super.onBackPressed();
    }

    @Override
    public void onBackStackChanged() {
        Log.d("onBackStackChanged", "Back stack changed.");
        if (canGoBack())
            mDrawerFragment.hideHamburger();
        else
            mDrawerFragment.showHamburger();
    }

    public boolean canGoBack() {
        return getSupportFragmentManager().getBackStackEntryCount() > 0;
    }

    private void initDrawerNavigation() {
        mDrawerFragment = (DrawerFragment)getSupportFragmentManager().findFragmentById(R.id.navigation_drawer);
        mDrawerFragment.setUp(R.id.navigation_drawer, (DrawerLayout)findViewById(R.id.main_drawer));
        mCurrentTitle = mDrawerFragment.getNavItems()[mDrawerFragment.getCurrentSelectedPosition()];
    }
    //endregion

    public boolean isTwoPane() {
        return getResources().getBoolean(R.bool.has_two_panes);
    }

}
