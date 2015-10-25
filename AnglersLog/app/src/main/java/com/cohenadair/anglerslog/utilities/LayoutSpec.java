package com.cohenadair.anglerslog.utilities;

import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;

import java.util.UUID;

/**
 * LayoutSpec is used to store layout information to utilize similar code throughout the
 * application.  For example, viewing and managing complex
 * {@link com.cohenadair.anglerslog.model.user_defines.UserDefineObject}s all use the same
 * master-detail layout with a {@link ManageFragment} for adding and editing.  This utility class
 * allows all that code to be recycled for any complex UserDefineObject subclass.
 *
 * The current layout is controlled by a {@link LayoutController} singleton class, and should never
 * be instantiated outside that instance.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public class LayoutSpec {

    private Fragment mMasterFragment;
    private ListManager.Adapter mMasterAdapter;
    private DetailFragment mDetailFragment;
    private ManageFragment mManageFragment;

    private OnUserDefineRemoveListener mOnUserDefineRemove;

    private String mMasterFragmentTag;
    private String mDetailFragmentTag;
    private String mName;

    private UUID mSelectionId;
    private int id;

    /**
     * Used to delete a user define. Editing is done in the Manage*Fragment for that user define.
     */
    public interface OnUserDefineRemoveListener {
        void remove(UUID id);
    }

    public LayoutSpec(String masterTag, String detailTag, String name) {
        mMasterFragmentTag = masterTag;
        mDetailFragmentTag = detailTag;
        mName = name;
    }

    //region Getters & Setters
    public void setManageFragment(ManageContentFragment contentFragment) {
        mManageFragment = new ManageFragment();
        mManageFragment.setContentFragment(contentFragment);
    }

    public Fragment getMasterFragment() {
        return mMasterFragment;
    }

    public void setMasterFragment(Fragment masterFragment, ListManager.Adapter adapter) {
        mMasterFragment = masterFragment;
        mMasterAdapter = adapter;
    }

    public DetailFragment getDetailFragment() {
        return mDetailFragment;
    }

    public void setDetailFragment(DetailFragment detailFragment) {
        mDetailFragment = detailFragment;
    }

    public ManageFragment getManageFragment() {
        return mManageFragment;
    }

    public ListManager.Adapter getMasterAdapter() {
        return mMasterAdapter;
    }

    public OnUserDefineRemoveListener getOnUserDefineRemove() {
        return mOnUserDefineRemove;
    }

    public void setOnUserDefineRemove(OnUserDefineRemoveListener onUserDefineRemove) {
        mOnUserDefineRemove = onUserDefineRemove;
    }

    public String getMasterFragmentTag() {
        return mMasterFragmentTag;
    }

    public String getDetailFragmentTag() {
        return mDetailFragmentTag;
    }

    public String getName() {
        return mName;
    }

    public UUID getSelectionId() {
        return mSelectionId;
    }

    public void setSelectionId(UUID selectionId) {
        this.mSelectionId = selectionId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
    //endregion

    /**
     * Updates the views for the master and detail fragments. This is called when changes were made
     * to the associated data sets.
     */
    public void updateViews() {
        mMasterAdapter.notifyDataSetChanged();
        mDetailFragment.update();
    }
}
