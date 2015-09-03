package com.cohenadair.anglerslog.activities;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.CatchesFragment;
import com.cohenadair.anglerslog.fragments.DrawerFragment;
import com.cohenadair.anglerslog.model.Logbook;

public class MainActivity extends ActionBarActivity implements
        CatchesFragment.OnListItemSelectedListener,
        DrawerFragment.DrawerFragmentCallbacks,
        FragmentManager.OnBackStackChangedListener
{

    private DrawerFragment mDrawerFragment;
    private CharSequence mCurrentTitle; // for use in {@link #restoreActionBar()}

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_layout);

        initFragments(savedInstanceState);
        initBackNavigation();
        initDrawerNavigation();

        // adds a small shadow to the bottom of the actionbar
        getSupportActionBar().setElevation(5);
    }

    @Override
    public void onDrawerItemSelected(int position) {
        // update action bar title
        if (mDrawerFragment != null)
            mCurrentTitle = mDrawerFragment.getNavItems()[position];

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

    // fragments can't be replaced unless added to the layout programmatically
    // see http://stackoverflow.com/questions/14810348/android-fragment-replace-doesnt-replace-content-puts-it-on-top
    private void initFragments(Bundle savedInstanceState) {
        // add the catches fragment to the layout
        if (findViewById(R.id.main_container) != null) {
            // avoid multiple fragments stacked on top of one another
            if (savedInstanceState != null)
                return;

            CatchesFragment fragment = new CatchesFragment();
            fragment.setArguments(getIntent().getExtras());

            getFragmentManager().beginTransaction().add(R.id.main_container, fragment).commit();
        }
    }

    //region CatchesFragment.OnListItemSelectedListener interface
    @Override
    public void onItemSelected(int pos) {
        Logbook.getInstance().setCurrentCatchPos(pos);

        CatchFragment catchFragment = (CatchFragment)findFragment(R.id.fragment_catch);

        if (isTwoPane())
            catchFragment.updateCatch(pos);
        else {
            // show the single catch fragment
            catchFragment = new CatchFragment();

            FragmentTransaction transaction = getFragmentManager().beginTransaction();
            transaction.replace(R.id.main_container, catchFragment)
                       .addToBackStack(null)
                       .commit();

            setActionBarTitle("");
        }
    }
    //endregion

    //region Navigation
    private void initBackNavigation() {
        if (!isTwoPane())
            getFragmentManager().addOnBackStackChangedListener(this);
    }

    private void handleBackPress() {
        if (!mDrawerFragment.isHamburgerVisible()) {
            getFragmentManager().popBackStack();
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
        if (canGoBack())
            mDrawerFragment.hideHamburger();
        else
            mDrawerFragment.showHamburger();
    }

    public boolean canGoBack() {
        return getFragmentManager().getBackStackEntryCount() > 0;
    }

    private void initDrawerNavigation() {
        mDrawerFragment = (DrawerFragment)getFragmentManager().findFragmentById(R.id.navigation_drawer);
        mDrawerFragment.setUp(R.id.navigation_drawer, (DrawerLayout)findViewById(R.id.main_drawer));
        mCurrentTitle = mDrawerFragment.getNavItems()[mDrawerFragment.getCurrentSelectedPosition()];
    }
    //endregion

    public boolean isTwoPane() {
        return getResources().getBoolean(R.bool.has_two_panes);
    }

    public Fragment findFragment(int resId) {
        return getFragmentManager().findFragmentById(resId);
    }

}
