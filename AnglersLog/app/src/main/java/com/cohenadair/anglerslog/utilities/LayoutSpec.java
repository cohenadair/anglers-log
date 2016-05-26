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
import com.cohenadair.anglerslog.model.utilities.SortingMethod;

import java.util.ArrayList;
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
 * @author Cohen Adair
 */
public class LayoutSpec {

    private Fragment mMasterFragment;
    private ListManager.Adapter mMasterAdapter;
    private DetailFragment mDetailFragment;
    private ManageFragment mManageFragment;
    private Intent mOnClickMenuItemIntent; // used for navigation drawer links (i.e. Twitter, Instagram)
    private SortingMethod[] mSortingMethods;

    private InteractionListener mListener;
    private OnSelectionListener mSelectionListener;
    private OnGetTitleCallback mOnGetTitleCallback;

    private String mMasterFragmentTag;
    private String mDetailFragmentTag;
    private String mName;

    private UUID mSelectionId;
    private int mId;

    /**
     * Used to delete a user define. Editing is done in the Manage*Fragment for that user define.
     */
    public interface InteractionListener {
        ListManager.Adapter onGetMasterAdapter(String searchQuery, SortingMethod sortingMethod, boolean allowsMultipleSelection);
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

    /**
     * Used to get the current layout's title. This interface is optional and by default the title
     * will get the layout's name + adapter's length.
     */
    public interface OnGetTitleCallback {
        String onGetTitle();
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

    public void setOnGetTitleCallback(OnGetTitleCallback onGetTitleCallback) {
        mOnGetTitleCallback = onGetTitleCallback;
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
            mMasterAdapter = mListener.onGetMasterAdapter(null, null, false);
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

    public SortingMethod[] getSortingMethods() {
        return mSortingMethods;
    }

    public void setSortingMethods(SortingMethod[] sortingMethods) {
        mSortingMethods = sortingMethods;
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

    /**
     * @return The navigation title used for this LayoutSpec.
     */
    public String getTitleName() {
        if (mOnGetTitleCallback != null)
            return mOnGetTitleCallback.onGetTitle();

        return (mMasterAdapter == null) ? mMasterFragmentTag : getTitleName(mMasterAdapter.getItemCount());
    }

    public String getTitleName(int numberOfItems) {
        return mMasterFragmentTag + " (" + numberOfItems + ")";
    }

    /**
     * Gets the id of a selected item. This is only used for tablets in two-pane mode. It will
     * show and store each item selected by the user.
     */
    public UUID getSelectionId() {
        // check to see if an item has previously been selected
        if (mSelectionId == null && mMasterAdapter != null)
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
        return mId;
    }

    public void setId(int id) {
        mId = id;
    }
    //endregion

    /**
     * Updates the views for the master and detail fragments. This is called when changes were made
     * to the associated data sets.
     *
     * @param activity The {@link LayoutSpecActivity} associated with this LayoutSpec instance.
     * @param searchQuery The String of keywords used to filter the RecyclerView's adapter.
     * @param sortingMethod The {@link SortingMethod} used to sort the RecyclerView's adapter.
     */
    public void updateViews(LayoutSpecActivity activity, String searchQuery, SortingMethod sortingMethod) {
        if (mListener == null || mDetailFragment == null)
            return;

        ArrayList<UUID> selectedIds = (mMasterAdapter == null) ? null : mMasterAdapter.getSelectedIds();
        boolean allowsMultipleSelection = (mMasterAdapter != null) && mMasterAdapter.isManagingMultipleSelections();

        mMasterAdapter = mListener.onGetMasterAdapter(searchQuery, sortingMethod, allowsMultipleSelection);
        mMasterAdapter.setSelectedIds(selectedIds);
        mMasterAdapter.notifyDataSetChanged();

        ((MasterFragment)mMasterFragment).updateInterface();
        mDetailFragment.update(activity);
    }

    /**
     * @see #updateViews(LayoutSpecActivity, String, SortingMethod)
     */
    public void updateViews(LayoutSpecActivity activity, String searchQuery) {
        updateViews(activity, searchQuery, null);
    }

    /**
     * @see #updateViews(LayoutSpecActivity, String, SortingMethod)
     */
    public void updateViews(LayoutSpecActivity activity, SortingMethod sortingMethod) {
        updateViews(activity, null, sortingMethod);
    }

    /**
     * @see #updateViews(LayoutSpecActivity, String, SortingMethod)
     */
    public void updateViews(LayoutSpecActivity activity) {
        updateViews(activity, null, null);
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
            AlertUtils.showError(context, obj.getName() + " " + context.getResources().getString(R.string.error_delete_primitive));
    }
}
