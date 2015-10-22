package com.cohenadair.anglerslog.activities;

import android.content.DialogInterface;
import android.content.Intent;
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
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.utilities.NavigationManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;

// TODO rename themes for convention
// TODO hide FAB unless user is at the top of the list (blocks rating star)

public class MainActivity extends AppCompatActivity implements
        MyListFragment.InteractionListener,
        ManageFragment.InteractionListener,
        OnClickManageMenuListener
{

    private OnClickInterface mOnMyListViewItemClick;
    private FragmentInfo mFragmentInfo;
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

        // this is passed to MyListFragment's RecyclerView's Adapter and ViewHolder objects
        mOnMyListViewItemClick = new OnClickInterface() {
            @Override
            public void onClick(View view, int position) {
                onMyListItemSelected(position);
            }
        };

        // needs to be called after MainActivity's initialization code
        showFragment(savedInstanceState);
    }

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

    public OnClickInterface getOnMyListViewItemClick() {
        return mOnMyListViewItemClick;
    }

    public void showFragment(@Nullable Bundle savedInstanceState) {
        mFragmentInfo = FragmentData.fragmentInfo(this, FragmentData.getCurrentFragmentId());
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

        // add left panel
        transaction.replace(R.id.master_container, mFragmentInfo.getFragment(), mFragmentInfo.getTag());

        // add the right panel if needed
        if (isTwoPane())
            transaction.replace(R.id.detail_container, mFragmentInfo.detailFragment(), mFragmentInfo.detailTag());

        // commit changes
        transaction.commit();
    }

    /**
     * A method called when the user wants to edit and object in the current MyListFragment
     * instance.
     */
    @Override
    public void onClickMenuEdit(int position) {
        mFragmentInfo.setManageContentIsEditing(true, position);
        mFragmentInfo.setManageContentDidPause(false);
        goToListManagerView();
    }

    /**
     * A method called when the user deletes an item from the list.
     * @param position The position of the item to be deleted.
     */
    @Override
    public void onClickMenuTrash(final int position) {
        Utils.showDeleteConfirm(this, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                mFragmentInfo.getOnUserDefineRemove().remove(position);
                mNavigationManager.goBack();
            }
        });
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
        mFragmentInfo.setManageContentIsEditing(false);
        mFragmentInfo.setManageContentDidPause(false);
        goToListManagerView();
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
        mFragmentInfo.updateViews();
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

    /**
     * Will open or display the manager view associated with the current master detail fragment.
     * For example, when the Catches list is open, this method will display the ManageCatchFragment.
     */
    private void goToListManagerView() {
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

            int preTextId = mFragmentInfo.manageContentIsEditing() ? R.string.action_edit : R.string.new_text;
            mNavigationManager.setActionBarTitle(getResources().getString(preTextId) + " " + mFragmentInfo.getName());
        }
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
