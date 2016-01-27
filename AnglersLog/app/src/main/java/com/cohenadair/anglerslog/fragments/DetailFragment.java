package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.interfaces.GlobalSettingsInterface;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailLayout;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The DetailFragment class is meant to be extended by any "detail" fragments.
 * A detail fragment is a fragment that shows details after a user selects an item from a list view.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public abstract class DetailFragment extends Fragment {

    private static final String TAG = "DetailFragment";

    private UUID mItemId;
    private OnClickManageMenuListener mMenuListener;

    /**
     * The method that updates the view using the object at the corresponding ListView position.
     * @param id the UUID of the clicked ListItem in the master view.
     */
    public abstract void update(UUID id);

    public DetailFragment() {

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        if (!shouldShowManageMenu())
            return;

        // make sure the container activity has implemented the callback interface
        try {
            mMenuListener = (OnClickManageMenuListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement OnClickManageMenuListener.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mMenuListener = null;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);

        if (shouldShowManageMenu()) {
            menu.clear();
            inflater.inflate(R.menu.menu_manage, menu);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        switch (id) {
            case R.id.action_edit:
                mMenuListener.onClickMenuEdit(mItemId);
                break;
            case R.id.action_trash:
                mMenuListener.onClickMenuTrash(mItemId);
                break;
            default:
                Log.e(TAG, "Menu item id: " + id + " is not supported.");
        }

        return super.onOptionsItemSelected(item);
    }

    public void update(Context context) {
        if (isLayoutSpecChild())
            update(((LayoutSpecActivity)context).getSelectionId());
        else
            update(getItemId());
    }

    public boolean isAttached() {
        return getActivity() != null;
    }

    //region Getters & Setters
    public UUID getItemId() {
        return mItemId;
    }

    public void setItemId(UUID itemId) {
        mItemId = itemId;
    }

    public LayoutSpecActivity getRealActivity() {
        return (LayoutSpecActivity)getActivity();
    }
    //endregion

    private boolean shouldShowManageMenu() {
        return getContext() instanceof OnClickManageMenuListener;
    }

    /**
     * @return True if this fragment is a child of a {@link LayoutSpecActivity}.
     */
    public boolean isLayoutSpecChild() {
        return getActivity() instanceof LayoutSpecActivity;
    }

    public boolean isTwoPane() {
        return (getActivity() instanceof GlobalSettingsInterface) && ((GlobalSettingsInterface)getActivity()).isTwoPane();
    }

    public void setActionBarTitle(String title) {
        if (!(getActivity() instanceof AppCompatActivity))
            return;

        ActionBar actionBar = ((AppCompatActivity)getActivity()).getSupportActionBar();
        if (actionBar != null)
            actionBar.setTitle(title);
    }

    /**
     * Shows a detail fragment embedded in an Activity.
     *
     * @param layoutSpecId The layout id for the UserDefineObject that will be shown.
     *                     See {@link com.cohenadair.anglerslog.utilities.LayoutSpecManager}.
     * @param userDefineObjectId The id of the UserDefineObject to be shown.
     */
    public void startDetailActivity(int layoutSpecId, UUID userDefineObjectId) {
        startActivity(Utils.getDetailActivityIntent(getContext(), layoutSpecId, userDefineObjectId));
    }

    /**
     * Gets an {@link com.cohenadair.anglerslog.views.MoreDetailLayout.OnUpdateItemInterface},
     * specifically for {@link Catch} objects. This method is used in multiple DetailFragment
     * subclasses.
     *
     * @param catches The {@link Catch} objects that will be displayed.
     * @return An {@link com.cohenadair.anglerslog.views.MoreDetailLayout.OnUpdateItemInterface}.
     */
    public MoreDetailLayout.OnUpdateItemInterface getCatchUpdateItemInterface(ArrayList<UserDefineObject> catches) {
        return new MoreDetailLayout.OnUpdateItemInterface() {
            @Override
            public String getTitle(UserDefineObject object) {
                return ((Catch)object).getSpeciesAsString();
            }

            @Override
            public String getSubtitle(UserDefineObject object) {
                return ((Catch)object).getDateTimeAsString();
            }

            @Override
            public View.OnClickListener onClickItemButton(final UUID id) {
                return new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_CATCHES, id);
                    }
                };
            }
        };
    }
}
