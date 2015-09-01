package com.cohenadair.anglerslog.activities;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.CatchesFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.Utilities;

public class MainActivity extends Activity implements CatchesFragment.OnListItemSelectedListener, FragmentManager.OnBackStackChangedListener {

    private String[] navItems;
    private ListView navList;
    private DrawerLayout drawerLayout;
    private ActionBarDrawerToggle drawerToggle;
    private String actionBarTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setContentView(R.layout.main_layout);

        this.initFragments(savedInstanceState);
        this.initBackNavigation();
        this.initDrawerNavigation();
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);

        // sync the toggle state after onRestoreInstaceState has occurred
        this.drawerToggle.syncState();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        this.drawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        this.getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // handle drawer navigation clicks first
        if (this.drawerToggle.onOptionsItemSelected(item))
            return true;

        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }

        // pop the next item off the back stack
        if (id == android.R.id.home) {
            this.getFragmentManager().popBackStack();
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
    public void initBackNavigation() {
        if (!this.isTwoPane()) {
            this.getFragmentManager().addOnBackStackChangedListener(this);
            Utilities.handleDisplayBackButton(this);
        } else
            Utilities.handleDisplayBackButton(this, false); // remove back button for landscape
    }

    public void initDrawerNavigation() {
        this.actionBarTitle = this.getResources().getString(R.string.app_name);
        this.navItems = this.getResources().getStringArray(R.array.navigation_items);
        this.navList = (ListView)this.findViewById(R.id.left_drawer);
        this.drawerLayout = (DrawerLayout)this.findViewById(R.id.main_drawer);

        this.drawerToggle = new ActionBarDrawerToggle(this, this.drawerLayout, R.drawable.ic_drawer, R.string.drawer_open, R.string.drawer_close) {
            public void onDrawerClosed(View v) {
                super.onDrawerClosed(v);
                Utilities.setActionBarTitle(MainActivity.this, MainActivity.this.actionBarTitle);
                MainActivity.this.invalidateOptionsMenu();
            }

            public void onDrawerOpened(View drawerView) {
                super.onDrawerClosed(drawerView);
                Utilities.setActionBarTitle(MainActivity.this, R.string.app_name);
                MainActivity.this.invalidateOptionsMenu();
            }
        };

        this.drawerLayout.setDrawerListener(this.drawerToggle);
        Utilities.handleDisplayBackButton(this, true);

        this.navList.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, this.navItems));
        this.navList.setOnItemClickListener(new DrawerItemClickListener());
    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener {
        @Override
        public void onItemClick(AdapterView parent, View view, int pos, long id) {
            MainActivity.this.onSelectDrawerItem(pos);
        }
    }

    private void onSelectDrawerItem(int pos) {
        Log.d("onSelectDrawerItem", "Selected item: " + pos);

        // Highlight the selected item, update the title, and close the drawer
        this.navList.setItemChecked(pos, true);
        Utilities.setActionBarTitle(this, this.navItems[pos]);
        this.actionBarTitle = this.navItems[pos];
        this.drawerLayout.closeDrawer(this.navList);
    }

    @Override
    public void onBackStackChanged() {
        Utilities.handleDisplayBackButton(this);
    }
    //endregion

    public boolean isTwoPane() {
        return this.getResources().getBoolean(R.bool.has_two_panes);
    }

}
