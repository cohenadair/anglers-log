package com.cohenadair.anglerslog.utilities.fragment;

import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.utilities.ListManager;

/**
 * LayoutSpec is used to store everything the UI needs to know about a fragment to properly
 * display it on the screen.  Having this class makes it extremely easy to display different
 * fragments (that have a similar UI) interchangeably throughout the application's lifecycle.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public class LayoutSpec {

    private ManageFragmentInfo mManageInfo;
    private LayoutSpec mDetailInfo;
    private ListManager.Adapter mArrayAdapter;
    private Fragment mFragment;
    private OnUserDefineRemoveListener mOnUserDefineRemove;
    private String mTag;
    private String mName; // used to set the ActionBar title
    private int prevSelectionPosition = 0;
    private int id;

    /**
     * Used to delete a user define. Editing is done in the Manage*Fragment for that user define.
     */
    public interface OnUserDefineRemoveListener {
        void remove(int position);
    }

    public LayoutSpec(String aTag) {
        setTag(aTag);
    }

    //region Getters & Setters
    public ManageFragmentInfo getManageInfo() {
        return mManageInfo;
    }

    public void setManageInfo(ManageFragmentInfo manageInfo) {
        mManageInfo = manageInfo;
    }

    public LayoutSpec getDetailInfo() {
        return mDetailInfo;
    }

    public void setDetailInfo(LayoutSpec detailInfo) {
        mDetailInfo = detailInfo;
    }

    public ListManager.Adapter getArrayAdapter() {
        return mArrayAdapter;
    }

    public void setArrayAdapter(ListManager.Adapter arrayAdapter) {
        mArrayAdapter = arrayAdapter;
    }

    public Fragment getFragment() {
        return mFragment;
    }

    public void setFragment(Fragment fragment) {
        mFragment = fragment;
    }

    public OnUserDefineRemoveListener getOnUserDefineRemove() {
        return mOnUserDefineRemove;
    }

    public void setOnUserDefineRemove(OnUserDefineRemoveListener onUserDefineRemove) {
        mOnUserDefineRemove = onUserDefineRemove;
    }

    public String getTag() {
        return mTag;
    }

    public void setTag(String tag) {
        mTag = tag;
    }

    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public int getPrevSelectionPosition() {
        return prevSelectionPosition;
    }

    public void setPrevSelectionPosition(int prevSelectionPosition) {
        this.prevSelectionPosition = prevSelectionPosition;
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

    public ManageFragment manageFragment() {
        return mManageInfo.getManageFragment();
    }

    public ManageContentFragment manageContentFragment() {
        return mManageInfo.getManageContentFragment();
    }

    public void setManageContentIsEditing(boolean isEditing, int itemPosition) {
        manageContentFragment().setIsEditing(isEditing, itemPosition);
    }

    public void setManageContentIsEditing(boolean isEditing) {
        manageContentFragment().setIsEditing(isEditing, -1);
    }

    public boolean manageContentIsEditing() {
        return manageContentFragment().isEditing();
    }

    /**
     * Updates the views for the master and detail fragments. This is called when changes were made
     * to the associated data sets.
     */
    public void updateViews() {
        mArrayAdapter.notifyDataSetChanged();
        ((DetailFragment)mDetailInfo.getFragment()).update();
    }
}
