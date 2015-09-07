package com.cohenadair.anglerslog.utilities.fragment;

import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.fragments.ManageFragment;

/**
 * The ManageFragmentInfo class stores information about management (add, edit) fragments.
 * Created by Cohen Adair on 2015-09-07.
 */
public class ManageFragmentInfo {

    private ManageFragment mManageFragment;
    private Fragment mManageContentFragment; // fragment for the actual content

    public ManageFragmentInfo(ManageFragment manageFragment, Fragment contentFragment) {
        mManageFragment = manageFragment;
        mManageContentFragment = contentFragment;
    }

    //region Getters & Setters
    public ManageFragment getManageFragment() {
        return mManageFragment;
    }

    public void setManageFragment(ManageFragment manageFragment) {
        mManageFragment = manageFragment;
    }

    public Fragment getManageContentFragment() {
        return mManageContentFragment;
    }

    public void setManageContentFragment(Fragment manageContentFragment) {
        mManageContentFragment = manageContentFragment;
    }
    //endregion
}
