package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

/**
 * The ManageContentFragment is the superclass of the content fragments used in ManageFragment
 * instances.
 *
 * Created by Cohen Adair on 2015-09-30.
 */
public abstract class ManageContentFragment extends Fragment {
    public abstract UserDefineObject getObject();
}
