package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.NavigationManager;
import com.cohenadair.anglerslog.utilities.RateDialog;
import com.cohenadair.anglerslog.utilities.ViewUtils;

import java.util.UUID;

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
        mNavigationManager.setUp(new NavigationManager.InteractionListener() {
            @Override
            public void onGoBack() {
                // must be called after updateViews()
                // this is used as a workaround for smoother fragment transitions; for whatever
                // reason the reverse animation off the back stack makes some views "go white",
                // and ScrollViews appear above the toolbar, making the animation look sloppy
                // StackOverflow issue: http://stackoverflow.com/questions/36204194/android-keep-actionbar-toolbar-in-front-of-fragment-animations
                getDetailFragment().hide();
            }
        });

        // needs to be called after MainActivity's initialization code
        // update the current layout
        updateLayoutSpec();

        // keep layout on orientation change
        if (savedInstanceState == null)
            showFragment();
        else
            setRightPanelVisibility();

        LogbookPreferences.setIsRootTwoPane(this, isTwoPane());
    }

    @Override
    protected void onStart() {
        super.onStart();

        // prompt the user to rate the app
        new RateDialog().showIfNeeded(this, getSupportFragmentManager());
    }

    /**
     * Needs to be implemented for children to receive onActivityResult calls.
     */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
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

        // add the right panel if needed
        if (hasRightPanel())
            transaction.replace(R.id.detail_container, getDetailFragment(), getDetailTag());

        setRightPanelVisibility();

        // commit changes
        transaction.commit();
    }

    //region MyListFragment.InteractionListener
    @Override
    public OnClickInterface getOnMyListFragmentItemClick() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                onMyListItemSelected(id);
            }
        };
    }

    @Override
    public boolean isSelecting() {
        return false;
    }

    @Override
    public boolean isSelectingMultiple() {
        return false;
    }
    //endregion

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
            getSupportFragmentManager().beginTransaction()
                    .setCustomAnimations(R.anim.slide_in_right, R.anim.slide_out_left, R.anim.slide_in_left, R.anim.slide_out_right)
                    .replace(R.id.master_container, getDetailFragment())
                    .addToBackStack(null)
                    .commitAllowingStateLoss();

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
            getSupportFragmentManager().beginTransaction()
                    //.setCustomAnimations(R.anim.slide_in_bottom, R.anim.slide_out_top, R.anim.slide_in_top, R.anim.slide_out_bottom)
                    .replace(R.id.master_container, getManageFragment())
                    .addToBackStack(null)
                    .commit();

            mNavigationManager.setActionBarTitle(getViewTitle());
        }
    }
    //endregion

    private boolean hasRightPanel() {
        return isTwoPane() && (getDetailFragment() != null);
    }

    private void setRightPanelVisibility() {
        // hide/show right panel if needed
        LinearLayout detailContainer = (LinearLayout)findViewById(R.id.detail_container);
        ViewUtils.setVisibility(detailContainer, hasRightPanel());
    }
}
