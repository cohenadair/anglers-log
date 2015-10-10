package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;

/**
 * The DetailFragment class is meant to be extended by any "detail" fragments.
 * A detail fragment is a fragment that shows details after a user selects an item from a list view.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public abstract class DetailFragment extends Fragment {

    private static final String TAG = "DetailFragment";

    private int mItemPosition = 0;
    private OnClickManageMenuListener mCallbacks;

    /**
     * The method that updates the view using the object at the corresponding ListView position.
     * @param position the position of the clicked ListItem in the master view.
     */
    public abstract void update(int position);

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
            mCallbacks = (OnClickManageMenuListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement DetailFragment.Interface.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_manage, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        switch (id) {
            case R.id.action_edit:
                mCallbacks.onClickMenuEdit(mItemPosition);
                break;
            case R.id.action_trash:
                mCallbacks.onClickMenuTrash(mItemPosition);
                break;
            default:
                Log.e(TAG, "Menu item id: " + id + " is not supported.");
        }

        return super.onOptionsItemSelected(item);
    }

    //region Getters & Setters
    public int getItemPosition() {
        return mItemPosition;
    }

    public void setItemPosition(int itemPosition) {
        mItemPosition = itemPosition;
    }
    //endregion
}
