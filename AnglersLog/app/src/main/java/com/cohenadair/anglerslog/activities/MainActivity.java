package com.cohenadair.anglerslog.activities;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.utilities.NavigationManager;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;

// TODO rename themes for convention
// TODO hide FAB unless user is at the top of the list (blocks rating star)

public class MainActivity extends AppCompatActivity implements
        MyListFragment.InteractionListener,
        ManageFragment.InteractionListener
{

    private OnClickInterface mOnMyListViewItemClick;
    private FragmentInfo mFragmentInfo;
    private NavigationManager mNavigationManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_layout);

        showFragment(savedInstanceState);

        // needed so the navigation view extends above and on top of the app bar
        Toolbar toolbar = (Toolbar)findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mNavigationManager = new NavigationManager(this);
        mNavigationManager.setUp();

        // this is passed to MyListFragment's RecyclerView's Adapter and ViewHolder objects
        mOnMyListViewItemClick = new OnClickInterface() {
            @Override
            public void onClick(View view, int position) {
                onMyListItemSelected(position);
            }
        };
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

    public OnClickInterface getOnMyListViewItemClick() {
        return mOnMyListViewItemClick;
    }

    public void showFragment(@Nullable Bundle savedInstanceState) {
        mFragmentInfo = FragmentData.fragmentInfo(this, FragmentData.getCurrentFragmentId());

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

    /**
     * Either show the detail fragment or update if it's already shown.
     */
    public void onMyListItemSelected(int position) {
        // update the current item for later
        FragmentData.selectionPos(FragmentData.getCurrentFragmentId(), position);

        DetailFragment detailFragment =
                (DetailFragment)getSupportFragmentManager().findFragmentByTag(mFragmentInfo.detailTag());

        if (isTwoPane() && detailFragment != null)
            // update the right panel detail fragment
            detailFragment.update(position);
        else {
            // show the single catch fragment
            detailFragment = (DetailFragment)mFragmentInfo.detailFragment();

            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, detailFragment)
                       .addToBackStack(null)
                       .commit();

            mNavigationManager.setActionBarTitle("");
        }
    }

    //region MyListFragment.InteractionListener interface
    /**
     * When the "new" FloatingActionButton is clicked. This button may not appear on all navigation
     * fragments.
     */
    @Override
    public void onMyListClickNewButton() {
        ManageFragment manageFragment = mFragmentInfo.manageFragment();

        if (isTwoPane()) {
            // show as popup dialog
            manageFragment.show(getSupportFragmentManager(), "dialog");
        } else {
            // show normally
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, manageFragment)
                       .addToBackStack(null)
                       .commit();

            mNavigationManager.setActionBarTitle(getResources().getString(R.string.new_text) + " " + mFragmentInfo.getName());
        }
    }
    //endregion

    //region ManageFragment.InteractionListener interface
    @Override
    public void onManageCancel() {
        mNavigationManager.goBack();
    }

    @Override
    public void onManageConfirm() {
        mNavigationManager.goBack();
    }
    //endregion

    //region Navigation
    @Override
    public void onBackPressed() {
        if (mNavigationManager.canGoBack())
            mNavigationManager.onBackPressed();
        else
            super.onBackPressed();
    }
    //endregion

    /**
     * Checks to see if the current layout has two-panes (i.e. master-detail layout).
     * @return True if there are two-panes; false otherwise.
     */
    public boolean isTwoPane() {
        return getResources().getBoolean(R.bool.has_two_panes);
    }
}
