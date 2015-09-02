package com.cohenadair.anglerslog.activities;

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

public class MainActivity extends ActionBarActivity implements CatchesFragment.OnListItemSelectedListener, DrawerFragment.DrawerFragmentCallbacks {

    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private DrawerFragment mDrawerFragment;

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
     */
    private CharSequence mTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setContentView(R.layout.main_layout);

        this.initFragments(savedInstanceState);
        //this.initBackNavigation();

        mDrawerFragment = (DrawerFragment)getFragmentManager().findFragmentById(R.id.navigation_drawer);
        mTitle = getTitle();

        mDrawerFragment.setUp(R.id.navigation_drawer, (DrawerLayout)findViewById(R.id.main_drawer));
    }

    @Override
    public void onDrawerItemSelected(int position) {
        Log.d("OnDrawerItemSelected", "Selected position: " + position);
    }

    public void onSectionAttached(int position) {
        mTitle = mDrawerFragment.getNavItems()[position];
    }

    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayShowTitleEnabled(true);
            actionBar.setTitle(mTitle);
        }
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
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    // fragments can't be replaced unless added to the layout programmatically
    // see http://stackoverflow.com/questions/14810348/android-fragment-replace-doesnt-replace-content-puts-it-on-top
    private void initFragments(Bundle savedInstanceState) {
        // add the catches fragment to the layout
        if (this.findViewById(R.id.main_container) != null) {
            // avoid multiple fragments stacked on top of one another
            if (savedInstanceState != null)
                return;

            CatchesFragment fragment = new CatchesFragment();
            fragment.setArguments(getIntent().getExtras());

            this.getFragmentManager().beginTransaction().add(R.id.main_container, fragment).commit();
        }
    }

    private CatchFragment findCatchFragment() {
        return (CatchFragment)this.getFragmentManager().findFragmentById(R.id.fragment_catch);
    }

    //region CatchesFragment.OnListItemSelectedListener interface
    public void onItemSelected(int pos) {
        Logbook.getSharedLogbook().setCurrentCatchPos(pos);

        CatchFragment catchFragment = this.findCatchFragment();

        if (catchFragment != null && catchFragment.isVisible()) // if two-pane
            catchFragment.updateCatch(pos);
        else {
            // show the single catch fragment
            catchFragment = new CatchFragment();

            FragmentTransaction transaction = this.getFragmentManager().beginTransaction();
            transaction.replace(R.id.main_container, catchFragment)
                       .addToBackStack(null)
                       .commit();
        }
    }
    //endregion

    //region Navigation
    /*
    public void initBackNavigation() {
        if (!this.isTwoPane()) {
            this.getFragmentManager().addOnBackStackChangedListener(this);
            Utilities.handleDisplayBackButton(this, this.canGoBack());
        } else
            Utilities.handleDisplayBackButton(this, false); // remove back button for landscape
    }

    private void onClickBack() {
        this.getFragmentManager().popBackStack();
    }

    @Override
    public void onBackStackChanged() {
        // show drawer button if there are no more navigation items on the stack
        if (!this.canGoBack())
            this.drawerToggle.setDrawerIndicatorEnabled(true);
    }
    //endregion
    */
    public boolean isTwoPane() {
        return this.getResources().getBoolean(R.bool.has_two_panes);
    }

    public boolean canGoBack() {
        return this.getFragmentManager().getBackStackEntryCount() > 0;
    }

}
