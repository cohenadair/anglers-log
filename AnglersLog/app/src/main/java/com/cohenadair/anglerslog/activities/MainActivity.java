package com.cohenadair.anglerslog.activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.utilities.LayoutController;
import com.cohenadair.anglerslog.utilities.NavigationManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.UUID;

// TODO rename themes for convention
// TODO hide FAB unless user is at the top of the list (blocks rating star)

public class MainActivity extends AppCompatActivity implements
        MyListFragment.InteractionListener,
        ManageFragment.InteractionListener,
        LayoutController.InteractionListener,
        OnClickManageMenuListener
{

    private static final String TAG = "MainActivity";

    private NavigationManager mNavigationManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_layout);

        // needed so the navigation view extends above and on top of the app bar
        Toolbar toolbar = (Toolbar)findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        ImageView cover = (ImageView)findViewById(R.id.nav_header_cover);

        mNavigationManager = new NavigationManager(this);
        mNavigationManager.setUp();

        // needs to be called after MainActivity's initialization code
        showFragment();
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
            LayoutController.updateViews();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void showFragment() {
        // update the current layout
        LayoutController.setCurrent(this, LayoutController.getCurrentId());

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

        // add left panel
        transaction.replace(R.id.master_container, LayoutController.getMasterFragment(), LayoutController.getMasterTag());

        // add the right panel if needed
        if (isTwoPane())
            transaction.replace(R.id.detail_container, LayoutController.getDetailFragment(), LayoutController.getDetailTag());

        // commit changes
        transaction.commit();
    }

    /**
     * A method called when the user wants to edit and object in the current MyListFragment
     * instance.
     */
    @Override
    public void onClickMenuEdit(UUID id) {
        LayoutController.setIsEditing(true, id);
        goToListManagerView();
    }

    /**
     * A method called when the user deletes an item from the list.
     * @param id The UUID of the item to be deleted.
     */
    @Override
    public void onClickMenuTrash(final UUID id) {
        Utils.showDeleteConfirm(this, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                LayoutController.removeUserDefine(id);
                mNavigationManager.goBack();
            }
        });
    }

    @Override
    public OnClickInterface getOnMyListFragmentItemClick() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID position) {
                onMyListItemSelected(position);
            }
        };
    }

    /**
     * Either show the detail fragment or update if it's already shown.
     */
    public void onMyListItemSelected(UUID position) {
        LayoutController.setSelectionId(position);

        DetailFragment detailFragment =
                (DetailFragment)getSupportFragmentManager().findFragmentByTag(LayoutController.getDetailTag());

        if (isTwoPane() && detailFragment != null)
            // update the right panel detail fragment
            detailFragment.update(position);
        else {
            // show the single catch fragment
            detailFragment = LayoutController.getDetailFragment();

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
        LayoutController.setIsEditing(false);
        goToListManagerView();
    }
    //endregion

    //region ManageFragment.InteractionListener interface
    @Override
    public void onManageDismiss() {
        mNavigationManager.goBack();
        LayoutController.updateViews();
    }
    //endregion

    //region Navigation
    @Override
    public void onBackPressed() {
        if (mNavigationManager.canGoBack()) {
            mNavigationManager.onBackPressed();
            LayoutController.updateViews();
        } else
            super.onBackPressed();
    }

    /**
     * Will open or display the manager view associated with the current master detail fragment.
     * For example, when the Catches list is open, this method will display the ManageCatchFragment.
     */
    private void goToListManagerView() {
        ManageFragment manageFragment = LayoutController.getManageFragment();

        if (isTwoPane()) {
            // show as popup dialog
            manageFragment.show(getSupportFragmentManager(), "dialog");
        } else {
            // show normally
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.replace(R.id.master_container, manageFragment)
                    .addToBackStack(null)
                    .commit();

            mNavigationManager.setActionBarTitle(LayoutController.getViewTitle(this));
        }
    }
    //endregion

    /**
     * Checks to see if the current layout has two-panes (i.e. master-detail layout).
     * @return True if there are two-panes; false otherwise.
     */
    public boolean isTwoPane() {
        return Utils.isTwoPane(this);
    }
}
