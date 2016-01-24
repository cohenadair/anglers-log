package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.interfaces.GlobalSettingsInterface;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailView;

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

    /**
     * An interface used for creating a list of {@link MoreDetailView}s.
     */
    public interface OnUpdateMoreDetailInterface {
        String onGetTitle(UserDefineObject object);
        String onGetSubtitle(UserDefineObject object);
        View.OnClickListener onGetDetailButtonClickListener(UUID id);
    }

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
        Intent intent = new Intent(getContext(), DetailFragmentActivity.class);
        intent.putExtra(DetailFragmentActivity.EXTRA_TWO_PANE, Utils.isTwoPane(getActivity()));
        intent.putExtra(DetailFragmentActivity.EXTRA_LAYOUT_ID, layoutSpecId);
        intent.putExtra(DetailFragmentActivity.EXTRA_USER_DEFINE_ID, userDefineObjectId.toString());
        startActivity(intent);
    }

    /**
     * Adds a list of {@link MoreDetailView}s to the given container.
     *
     * @param objects The {@link UserDefineObject} array of items to display.
     * @param titleView The header or title view for the list.
     * @param container The container for the list.
     * @param callbacks The callbacks each {@link MoreDetailView} behavior.
     */
    public void addMoreDetailViews(ArrayList<UserDefineObject> objects, View titleView, LinearLayout container, OnUpdateMoreDetailInterface callbacks) {
        boolean hasObjects = objects.size() > 0;
        Utils.toggleVisibility(titleView, hasObjects);
        Utils.toggleVisibility(container, hasObjects);

        container.removeAllViews();

        for (UserDefineObject object : objects) {
            MoreDetailView view = new MoreDetailView(getContext());
            view.setTitle(callbacks.onGetTitle(object));
            view.useDefaultStyle();

            if (callbacks.onGetSubtitle(object) == null)
                view.hideSubtitle();
            else
                view.setSubtitle(callbacks.onGetSubtitle(object));

            if (objects.size() == 1)
                view.useNoSpacing();
            else
                view.useDefaultSpacing();

            view.setOnClickDetailButton(callbacks.onGetDetailButtonClickListener(object.getId()));
            container.addView(view);
        }
    }
}
