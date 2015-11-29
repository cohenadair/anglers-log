package com.cohenadair.anglerslog.activities;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.utilities.LayoutSpec;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.UUID;

/**
 * A wrapper class to be used for any Activity that requires a {@link LayoutSpec} object.
 */
public abstract class LayoutSpecActivity extends AppCompatActivity implements
        MyListFragment.InteractionListener,
        ManageFragment.InteractionListener,
        LayoutSpecManager.InteractionListener,
        OnClickManageMenuListener
{

    /**
     * Will open or display the manager view associated with the current master detail fragment.
     * For example, when the Catches list is open, this method will display the ManageBaitFragment.
     */
    public abstract void goToListManagerView();

    /**
     * Performs the back operation.
     */
    public abstract void goBack();

    private LayoutSpec mLayoutSpec;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public LayoutSpec getLayoutSpec() {
        return mLayoutSpec;
    }

    public void setLayoutSpec(LayoutSpec layoutSpec) {
        mLayoutSpec = layoutSpec;
    }

    //region LayoutSpec Wrapper Methods
    public String getName() {
        return mLayoutSpec.getName();
    }

    public boolean isEditing() {
        return mLayoutSpec.getManageFragment().getContentFragment().isEditing();
    }

    public void setIsEditing(boolean isEditing) {
        mLayoutSpec.getManageFragment().getContentFragment().setIsEditing(isEditing, null);
    }

    public void setIsEditing(boolean isEditing, UUID id) {
        mLayoutSpec.getManageFragment().getContentFragment().setIsEditing(isEditing, id);
    }

    public void setSelectionId(UUID id) {
        mLayoutSpec.setSelectionId(id);
    }

    public UUID getSelectionId() {
        return mLayoutSpec.getSelectionId();
    }

    public void removeUserDefine(UUID id) {
        mLayoutSpec.getListener().onUserDefineRemove(id);
    }

    public Fragment getMasterFragment() {
        return mLayoutSpec.getMasterFragment();
    }

    public DetailFragment getDetailFragment() {
        return mLayoutSpec.getDetailFragment();
    }

    public ManageFragment getManageFragment() {
        return mLayoutSpec.getManageFragment();
    }

    public ManageContentFragment getManageContentFragment() {
        return mLayoutSpec.getManageFragment().getContentFragment();
    }

    public ListManager.Adapter getMasterAdapter() {
        return mLayoutSpec.getMasterAdapter();
    }

    public String getMasterTag() {
        return mLayoutSpec.getMasterFragmentTag();
    }

    public String getDetailTag() {
        return mLayoutSpec.getDetailFragmentTag();
    }

    public void updateViews() {
        mLayoutSpec.updateViews(this);
    }
    // endregion

    @NonNull
    public String getViewTitle() {
        return getResources().getString(isEditing() ? R.string.action_edit : R.string.new_text) + " " + mLayoutSpec.getName();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        updateViews();
    }

    //region ManageFragment.InteractionListener interface
    @Override
    public void onManageDismiss() {
        goBack();
        updateViews();
    }
    //endregion

    //region MyListFragment.InteractionListener interface
    /**
     * When the "new" FloatingActionButton is clicked. This button may not appear on all navigation
     * fragments.
     */
    @Override
    public void onMyListClickNewButton() {
        setIsEditing(false);
        goToListManagerView();
    }
    //endregion

    //region OnClickManageMenuListener interface
    /**
     * A method called when the user wants to edit and object in the current MyListFragment
     * instance.
     */
    @Override
    public void onClickMenuEdit(UUID id) {
        setIsEditing(true, id);
        goToListManagerView();
    }

    /**
     * A method called when the user deletes an item from the list.
     * @param id The UUID of the item to be deleted.
     */
    @Override
    public void onClickMenuTrash(final UUID id) {
        Utils.showDeleteConfirm(this, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                removeUserDefine(id);
                goBack();
            }
        });
    }
    //endregion
}
