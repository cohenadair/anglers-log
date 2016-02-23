package com.cohenadair.anglerslog.utilities;

import android.support.design.widget.NavigationView;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;

/**
 * A wrapper class to manage drawer navigation.
 * Created by Cohen Adair on 2015-09-16.
 */
public class NavigationManager implements FragmentManager.OnBackStackChangedListener {

    private DrawerLayout mDrawerLayout;
    private NavigationView mNavigationView;
    private ActionBar mActionBar;
    private MainActivity mActivity;
    private InteractionListener mCallbacks;

    public interface InteractionListener {
        void onOpenDrawer();
    }

    public NavigationManager(MainActivity activity) {
        mActivity = activity;
        mDrawerLayout = (DrawerLayout)mActivity.findViewById(R.id.main_drawer);
        mActionBar = mActivity.getSupportActionBar();

        mNavigationView = (NavigationView)mActivity.findViewById(R.id.navigation_view);
        mNavigationView.setItemIconTintList(null);

        for (int i = 0; i < mNavigationView.getMenu().size(); i++) {
            MenuItem item = mNavigationView.getMenu().getItem(i);
            item.setChecked(item.getItemId() == getCurrentLayoutId());

            // keep original colors for Instagram and Twitter links
            if (item.getItemId() != LayoutSpecManager.LAYOUT_INSTAGRAM &&
                item.getItemId() != LayoutSpecManager.LAYOUT_TWITTER)
                item.getIcon().setAlpha(75);
        }

        initHeaderView();
    }

    /**
     * Instances of this class must call this method after initialization.
     */
    public void setUp() {
        mNavigationView.setNavigationItemSelectedListener(new NavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem menuItem) {
                return onDrawerItemSelected(menuItem);
            }
        });

        mActivity.getSupportFragmentManager().addOnBackStackChangedListener(this);

        mActionBar.setDisplayHomeAsUpEnabled(true);
        showMenuButton();
        restoreActionBar();
    }

    public void setUp(InteractionListener callbacks) {
        setUp();
        mCallbacks = callbacks;
    }

    public void initHeaderView() {
        mNavigationView.inflateHeaderView(R.layout.navigation_header);
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
        else {
            if (mCallbacks != null)
                mCallbacks.onOpenDrawer();

            mDrawerLayout.openDrawer(GravityCompat.START);
        }
    }

    public void restoreActionBar() {
        mActionBar.setDisplayShowTitleEnabled(true);
        updateTitle();
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

    private boolean onDrawerItemSelected(MenuItem menuItem) {
        int itemId = menuItem.getItemId();

        // if the item selected is an external link
        if (LayoutSpecManager.isLink(itemId)) {
            LayoutSpec spec = LayoutSpecManager.layoutSpec(mActivity, itemId);
            if (spec != null)
                mActivity.startActivity(spec.getOnClickMenuItemIntent());

            return false;
        }

        setCurrentLayoutId(itemId);
        mActivity.updateLayoutSpec();
        mActivity.showFragment();
        restoreActionBar();

        menuItem.setChecked(true);
        mDrawerLayout.closeDrawers();

        return true;
    }

    public int getCurrentLayoutId() {
        return LogbookPreferences.getNavigationId();
    }

    public void setCurrentLayoutId(int id) {
        LogbookPreferences.setNavigationId(id);
    }

    public void updateTitle() {
        if (mActivity.getLayoutSpec() != null)
            mActionBar.setTitle(mActivity.getLayoutSpec().getPluralName());
    }
}
