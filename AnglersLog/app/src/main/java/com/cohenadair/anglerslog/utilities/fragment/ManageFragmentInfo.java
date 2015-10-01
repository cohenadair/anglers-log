package com.cohenadair.anglerslog.utilities.fragment;

import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;

/**
 * The ManageFragmentInfo class stores information about management (add, edit) fragments.
 * Created by Cohen Adair on 2015-09-07.
 */
public class ManageFragmentInfo {

    private ManageFragment mManageFragment;
    private ManageContentFragment mManageContentFragment; // fragment for the actual content

    public ManageFragmentInfo(ManageFragment manageFragment, ManageContentFragment contentFragment) {
        mManageFragment = manageFragment;
        mManageContentFragment = contentFragment;
    }

    //region Getters & Setters
    public ManageFragment getManageFragment() {
        return mManageFragment;
    }

    public ManageContentFragment getManageContentFragment() {
        return mManageContentFragment;
    }
    //endregion
}
