package com.cohenadair.anglerslog.utilities;

import android.app.Fragment;
import android.widget.ArrayAdapter;

/**
 * FragmentInfo is used to store everything the UI needs to know about a fragment to properly
 * display it on the screen.  Having this class makes it extremely easy to display different
 * fragments interchangeably throughout the application's lifecycle.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public class FragmentInfo {

    private FragmentInfo mDetailInfo;
    private ArrayAdapter mArrayAdapter;
    private Fragment mFragment;
    private String mTag;
    private int id;

    public FragmentInfo(String aTag) {
        setTag(aTag);
    }

    //region Getters & Setters
    public FragmentInfo getDetailInfo() {
        return mDetailInfo;
    }

    public void setDetailInfo(FragmentInfo detailInfo) {
        mDetailInfo = detailInfo;
    }

    public ArrayAdapter getArrayAdapter() {
        return mArrayAdapter;
    }

    public void setArrayAdapter(ArrayAdapter arrayAdapter) {
        mArrayAdapter = arrayAdapter;
    }

    public Fragment getFragment() {
        return mFragment;
    }

    public void setFragment(Fragment fragment) {
        mFragment = fragment;
    }

    public String getTag() {
        return mTag;
    }

    public void setTag(String tag) {
        mTag = tag;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
    //endregion

    public String detailTag() {
        return mDetailInfo.getTag();
    }

    public Fragment detailFragment() {
        return mDetailInfo.getFragment();
    }
}
