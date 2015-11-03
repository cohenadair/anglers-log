package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.utilities.Utils;

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
    public abstract void update();

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

        if (isVisible()) {
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

    public boolean isAttached() {
        return getActivity() != null;
    }

    public boolean isTwoPane() {
        return Utils.isTwoPane(getContext());
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
}
