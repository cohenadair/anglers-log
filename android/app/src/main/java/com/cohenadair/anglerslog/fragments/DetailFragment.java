package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.interfaces.GlobalSettingsInterface;

import java.util.UUID;

/**
 * The DetailFragment class is meant to be extended by any "detail" fragments.
 * A detail fragment is a fragment that shows details after a user selects an item from a list view.
 *
 * @author Cohen Adair
 */
public abstract class DetailFragment extends Fragment {

    private UUID mItemId;
    private OnClickMenuListener mMenuListener;
    private LinearLayout mContainer;

    public interface OnClickMenuListener {
        void onClickMenuEdit(UUID objId);
        void onClickMenuTrash(UUID objId);
        void onClickShare(UUID objId);
    }

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
            mMenuListener = (DetailFragment.OnClickMenuListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement DetailFragment.OnClickMenuListener.");
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

        if (isVisible() && shouldShowManageMenu()) {
            if (!isTwoPane())
                menu.clear();

            inflater.inflate(R.menu.menu_manage, menu);
        }

        // inflate the share menu no matter what
        inflater.inflate(R.menu.menu_share, menu);
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
            case R.id.action_share:
                mMenuListener.onClickShare(mItemId);
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * Used to hide all details of the fragment. This is used as a workaround to make fragment
     * transaction animations smoother. See navigation setup in
     * {@link com.cohenadair.anglerslog.activities.MainActivity#onCreate(Bundle)}.
     */
    public void hide() {
        if (mContainer != null)
            mContainer.setVisibility(View.GONE);
    }

    /**
     * @see #hide()
     */
    public void show() {
        if (mContainer != null)
            mContainer.setVisibility(View.VISIBLE);
    }

    /**
     * Updates the UI of the fragment.
     */
    public void update(Context context) {
        if (!isTwoPane())
            setActionBarTitle("");

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

    public LinearLayout getContainer() {
        return mContainer;
    }

    public void setContainer(LinearLayout container) {
        mContainer = container;
    }
    //endregion

    private boolean shouldShowManageMenu() {
        return getContext() instanceof DetailFragment.OnClickMenuListener;
    }

    /**
     * @return True if this fragment is a child of a {@link LayoutSpecActivity}, false otherwise.
     */
    public boolean isLayoutSpecChild() {
        return getActivity() instanceof LayoutSpecActivity;
    }

    /**
     * @return True if the current layout is two-pane; false otherwise.
     */
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

    public void clearActionBarTitle() {
        if (isTwoPane() || !isVisible())
            return;

        setActionBarTitle("");
    }

    /**
     * Shows a detail fragment embedded in an Activity.
     *
     * @param layoutSpecId The layout id for the UserDefineObject that will be shown.
     *                     See {@link com.cohenadair.anglerslog.utilities.LayoutSpecManager}.
     * @param userDefineObjectId The id of the UserDefineObject to be shown.
     */
    public void startDetailActivity(int layoutSpecId, UUID userDefineObjectId) {
        startActivity(DetailFragmentActivity.getIntent(getContext(), layoutSpecId, userDefineObjectId));
    }
}
