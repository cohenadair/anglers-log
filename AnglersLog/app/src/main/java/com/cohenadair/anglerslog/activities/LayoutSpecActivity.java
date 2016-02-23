package com.cohenadair.anglerslog.activities;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.SearchView;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.interfaces.GlobalSettingsInterface;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.utilities.LayoutSpec;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.List;
import java.util.UUID;

/**
 * A wrapper class to be used for any Activity that requires a {@link LayoutSpec} object.
 */
public abstract class LayoutSpecActivity extends DefaultActivity implements
        MyListFragment.InteractionListener,
        ManageFragment.InteractionListener,
        LayoutSpecManager.InteractionListener,
        OnClickManageMenuListener,
        GlobalSettingsInterface
{
    private static final String TAG = "LayoutSpecActivity";

    /**
     * Will open or display the manager view associated with the current master detail fragment.
     * For example, when the Catches list is open, this method will display the ManageBaitFragment.
     */
    public abstract void goToListManagerView();

    /**
     * Performs the back operation.
     */
    public abstract void goBack();

    private Menu mMenu;
    private MenuItem mSearchItem;
    private SearchView mSearchView;
    private LayoutSpec mLayoutSpec;

    private String mSearchText = "";
    private boolean mSearchIsExpanded = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        closeDialogs();
    }

    /**
     * Used to close any DialogFragment subclasses that are opened. This is to avoid a shit-ton of
     * pointer issues on orientation change.
     *
     * A judgement call was made and the amount a user will rotate the device while a dialog is
     * actually open is so small that it is not worth the trouble.  Also, it isn't likely that ever
     * pointer issue will be found, so it's better to close the dialogs than have the app crash.
     */
    private void closeDialogs() {
        List<Fragment> fragments = getSupportFragmentManager().getFragments();
        if (fragments != null)
            for (Fragment f : fragments)
                if (f instanceof DialogFragment)
                    ((DialogFragment) f).dismiss();
    }

    public LayoutSpec getLayoutSpec() {
        return mLayoutSpec;
    }

    public void setLayoutSpec(LayoutSpec layoutSpec) {
        mLayoutSpec = layoutSpec;
        updateMenu();
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

    public boolean removeUserDefine(UUID id) {
        return mLayoutSpec.getListener().onUserDefineRemove(id);
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

    public void updateViews(String searchQuery) {
        mLayoutSpec.updateViews(this, searchQuery);
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
    public void onManageDismiss(boolean isDialog) {
        if (!isDialog)
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
        if (id == null) // for tablets with no entries
            return;

        setIsEditing(true, id);
        goToListManagerView();
    }

    /**
     * A method called when the user deletes an item from the list.
     * @param id The UUID of the item to be deleted.
     */
    @Override
    public void onClickMenuTrash(final UUID id) {
        if (id == null) // for tablets with no entries
            return;

        Utils.showDeleteConfirm(this, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (removeUserDefine(id))
                    goBack();
            }
        });
    }
    //endregion

    public void updateMenu() {
        if (mSearchItem != null)
            mSearchItem.setVisible(mLayoutSpec.isSearchable());
    }

    public void setActionBarTitle(String title) {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
            actionBar.setTitle(title);
    }

    /**
     * Checks to see if the current layout has two-panes (i.e. master-detail layout).
     * @return True if there are two-panes; false otherwise.
     */
    @Override
    public boolean isTwoPane() {
        return Utils.isTwoPane(this);
    }

    //region Searching
    public Menu getMenu() {
        return mMenu;
    }

    public MenuItem getSearchItem() {
        return mSearchItem;
    }

    public void initSearch(Menu menu) {
        // don't initialize searching if it isn't the master fragment that is visible
        // this is needed to properly preserve the SearchView's state after fragment transactions
        if (!mLayoutSpec.getMasterFragment().isVisible())
            return;

        mMenu = menu;
        mSearchItem = mMenu.findItem(R.id.action_search);
        mSearchView = (SearchView)mSearchItem.getActionView();
        mSearchView.setQuery(mSearchText, false);
        mSearchView.setIconified(!mSearchIsExpanded);
        setMenuItemsVisibility(!mSearchIsExpanded);
        updateMenu();

        mSearchView.setOnSearchClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setMenuItemsVisibility(false);

                // update hint
                String search = getResources().getString(R.string.search);
                mSearchView.setQueryHint(search + " " + mLayoutSpec.getPluralName().toLowerCase());
                mSearchIsExpanded = true;
            }
        });

        mSearchView.setOnCloseListener(new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                setMenuItemsVisibility(true);
                resetSearch();

                // returning false will "iconify" the SearchView
                return false;
            }
        });

        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                updateViews(query);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                mSearchText = newText;
                if (newText.isEmpty())
                    updateViews();
                return false;
            }
        });
    }

    public void iconifySearchView() {
        if (mSearchView != null && !mSearchView.isIconified()) {
            resetSearch();
            mSearchView.setIconified(true);
        }
    }

    public void resetSearch() {
        mSearchText = "";
        mSearchIsExpanded = false;
        mSearchView.setQuery("", false);
        updateViews();
    }
    //endregion

    public void setMenuItemsVisibility(boolean visible) {
        for (int i = 0; i < mMenu.size(); i++) {
            MenuItem item = mMenu.getItem(i);
            if (item != mSearchItem)
                item.setVisible(visible);
        }
    }
}
