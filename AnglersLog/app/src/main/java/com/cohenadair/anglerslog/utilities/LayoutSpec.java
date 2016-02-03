package com.cohenadair.anglerslog.utilities;

import android.content.Intent;
import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MasterFragment;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.UUID;

/**
 * LayoutSpec is used to store layout information to utilize similar code throughout the
 * application.  For example, viewing and managing complex
 * {@link com.cohenadair.anglerslog.model.user_defines.UserDefineObject}s all use the same
 * master-detail layout with a {@link ManageFragment} for adding and editing.  This utility class
 * allows all that code to be recycled for any complex UserDefineObject subclass.
 *
 * The current layout is controlled by a {@link LayoutSpecManager} singleton class, and should never
 * be instantiated outside that instance.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public class LayoutSpec {

    private Fragment mMasterFragment;
    private ListManager.Adapter mMasterAdapter;
    private DetailFragment mDetailFragment;
    private ManageFragment mManageFragment;
    private Intent mOnClickMenuItemIntent;

    private InteractionListener mListener;
    private OnSelectionListener mSelectionListener;

    private String mMasterFragmentTag;
    private String mDetailFragmentTag;
    private String mName;

    private UUID mSelectionId;
    private int id;

    /**
     * Used to delete a user define. Editing is done in the Manage*Fragment for that user define.
     */
    public interface InteractionListener {
        ListManager.Adapter onGetMasterAdapter();
        boolean onUserDefineRemove(UUID id);
    }

    /**
     * Used in {@link com.cohenadair.anglerslog.activities.MyListSelectionActivity} instances for
     * specific behavior for different LayoutSpec instances.
     */
    public interface OnSelectionListener {
        void onSelect(UUID selectionId, OnSelectionFinishedCallback callback);
    }

    /**
     * Used in combination with {@link com.cohenadair.anglerslog.utilities.LayoutSpec.OnSelectionListener}
     * as a callback for when the "sub" selection is finished.
     */
    public interface OnSelectionFinishedCallback {
        void onFinish(UUID id);
    }

    public LayoutSpec() {

    }

    public LayoutSpec(String pluralName, String singularName) {
        mMasterFragmentTag = pluralName;
        mDetailFragmentTag = singularName.toLowerCase();
        mName = singularName;
    }

    //region Getters & Setters
    public OnSelectionListener getSelectionListener() {
        return mSelectionListener;
    }

    public void setSelectionListener(OnSelectionListener selectionListener) {
        mSelectionListener = selectionListener;
    }

    public void setManageFragment(ManageContentFragment contentFragment) {
        mManageFragment = new ManageFragment();
        mManageFragment.setContentFragment(contentFragment);
    }

    public Fragment getMasterFragment() {
        return mMasterFragment;
    }

    public void setMasterFragment(Fragment masterFragment) {
        mMasterFragment = masterFragment;

        if (mListener != null)
            mMasterAdapter = mListener.onGetMasterAdapter();
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

    public Intent getOnClickMenuItemIntent() {
        return mOnClickMenuItemIntent;
    }

    public void setOnClickMenuItemIntent(Intent onClickMenuItemIntent) {
        mOnClickMenuItemIntent = onClickMenuItemIntent;
    }

    public ListManager.Adapter getMasterAdapter() {
        return mMasterAdapter;
    }

    public InteractionListener getListener() {
        return mListener;
    }

    public void setListener(InteractionListener listener) {
        mListener = listener;
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

    public String getPluralName() {
        return mMasterFragmentTag;
    }

    public UUID getSelectionId() {
        // check to see if an item has previously been selected
        if (mSelectionId == null)
            for (int i = 0; i < mMasterAdapter.getItemCount(); i++) {
                UserDefineObject item = mMasterAdapter.getItem(i);
                if (item.getIsSelected()) {
                    mSelectionId = item.getId();
                    break;
                }
            }

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
    public void updateViews(LayoutSpecActivity activity) {
        if (mListener == null || mDetailFragment == null)
            return;

        mMasterAdapter = mListener.onGetMasterAdapter();
        mMasterAdapter.notifyDataSetChanged();

        ((MasterFragment)mMasterFragment).update(activity);
        mDetailFragment.update(activity);
    }

    /**
     * A helper function for removing user defines. Removes repeated code.
     *
     * @param context The Context.
     * @param obj The UserDefineObject to be removed.
     * @param didRemove Whether or not the object was removed.
     * @param successId The success message id.
     */
    public void removeUserDefine(LayoutSpecActivity context, UserDefineObject obj, boolean didRemove, int successId) {
        if (didRemove) {
            updateViews(context);
            Utils.showToast(context, successId);
        } else
            Utils.showErrorAlert(context, obj.getName() + " " + context.getResources().getString(R.string.error_delete_primitive));
    }
}
