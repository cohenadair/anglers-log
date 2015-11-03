package com.cohenadair.anglerslog.utilities;

import android.support.design.widget.NavigationView;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;
import com.cohenadair.anglerslog.model.Logbook;

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
    private int mCurrentLayoutId = LayoutSpecManager.LAYOUT_CATCHES;

    public NavigationManager(MainActivity activity) {
        mActivity = activity;
        mDrawerLayout = (DrawerLayout)mActivity.findViewById(R.id.main_drawer);
        mActionBar = mActivity.getSupportActionBar();

        mNavigationView = (NavigationView)mActivity.findViewById(R.id.navigation_view);
        initHeaderView();

        Menu menu = mNavigationView.getMenu();
        for (int i = 0; i < menu.size(); i++)
            if (menu.getItem(i).isChecked()) {
                mCurrentTitle = menu.getItem(i).getTitle().toString();
                break;
            }
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
        restoreActionBar();
    }

    public void initHeaderView() {
        View headerLayout = mNavigationView.inflateHeaderView(R.layout.navigation_header);
        ImageView cover = (ImageView)headerLayout.findViewById(R.id.nav_header_cover);
        final TextView title = (TextView)headerLayout.findViewById(R.id.nav_header_title);

        cover.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                v.removeOnLayoutChangeListener(this);

                String randomPhoto = Logbook.getRandomCatchPhoto();
                if (randomPhoto != null) {
                    String path = PhotoUtils.privatePhotoPath(randomPhoto);
                    PhotoUtils.photoToImageView((ImageView) v, path, v.getWidth(), v.getHeight());
                    title.setVisibility(View.INVISIBLE);
                }
            }
        });
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
        mCurrentLayoutId = menuItem.getItemId();
        mCurrentTitle = menuItem.getTitle().toString();
        mActivity.showFragment();
        restoreActionBar();

        menuItem.setChecked(true);
        mDrawerLayout.closeDrawers();
    }

    public int getCurrentLayoutId() {
        return mCurrentLayoutId;
    }
}
