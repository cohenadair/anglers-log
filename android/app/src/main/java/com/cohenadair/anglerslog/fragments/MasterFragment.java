package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.SearchView;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;

/**
 * An abstract class for master fragments used throughout the application.
 * @author Cohen Adair
 */
public abstract class MasterFragment extends Fragment {

    private boolean mClearMenuOnCreate;

    /**
     * Used to manage the App Bar's menu, including preserving search queries and the SearchView
     * through Fragment transactions.
     */
    private Menu mMenu;
    private SearchView mSearchView;
    private MenuItem mSearchItem;
    private String mSearchText = "";
    private boolean mSearchIsExpanded = false;
    private SearchInteractionListener mSearchInteractionListener;

    protected interface SearchInteractionListener {
        void onIconClicked();
        void onClose();
        void onTextSubmit(String query);
        void onTextChanged(String newText);
        void onReset();
    }

    public abstract void updateInterface();

    public LayoutSpecActivity getRealActivity() {
        return (LayoutSpecActivity)getActivity();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        mMenu = menu;
        if (mClearMenuOnCreate) {
            mMenu.clear();
        }

        initSearchIfNeeded();

        super.onCreateOptionsMenu(menu, inflater);
    }

    //region Getters & Setters
    public Menu getMenu() {
        return mMenu;
    }

    public void setClearMenuOnCreate(boolean clearMenuOnCreate) {
        mClearMenuOnCreate = clearMenuOnCreate;
    }

    public void setSearchInteractionListener(SearchInteractionListener searchInteractionListener) {
        mSearchInteractionListener = searchInteractionListener;
    }
    //endregion

    //region Searching
    private void initSearchIfNeeded() {
        mSearchItem = mMenu.findItem(R.id.action_search);
        if (mSearchItem == null) {
            return;
        }

        mSearchView = (SearchView) mSearchItem.getActionView();
        mSearchView.setIconified(!mSearchIsExpanded);

        // remove the extra space between the SearchView and menu icon
        mSearchView.setMaxWidth(Integer.MAX_VALUE);
        mSearchView.setPadding(
                getResources().getDimensionPixelOffset(R.dimen.margin_default_negative_cutoff),
                mSearchView.getPaddingTop(),
                mSearchView.getPaddingRight(),
                mSearchView.getPaddingBottom()
        );

        mSearchView.setOnSearchClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mSearchInteractionListener != null) {
                    mSearchInteractionListener.onIconClicked();
                }

                mSearchIsExpanded = true;
            }
        });

        mSearchView.setOnCloseListener(new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                setMenuItemsVisibility(true);
                resetSearch();

                if (mSearchInteractionListener != null) {
                    mSearchInteractionListener.onClose();
                }

                // returning false will "iconify" the SearchView
                return false;
            }
        });

        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                if (mSearchInteractionListener != null) {
                    mSearchInteractionListener.onTextSubmit(query);
                }
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                if (mSearchInteractionListener != null) {
                    mSearchInteractionListener.onTextChanged(newText);
                }
                return false;
            }
        });

        if (mSearchIsExpanded)
            mSearchView.setQuery(mSearchText, true);

        setMenuItemsVisibility(!mSearchIsExpanded);
    }

    private void resetSearch() {
        mSearchText = "";
        mSearchIsExpanded = false;
        mSearchView.setQuery("", false);

        if (mSearchInteractionListener != null) {
            mSearchInteractionListener.onReset();
        }
    }

    /**
     * Sets the search view's EditText hint.
     * @param hint The hint text.
     */
    protected void setSearchQueryHint(String hint) {
        mSearchView.setQueryHint(hint);
    }

    /**
     * Hides or shows all menu icons.
     * @param visible True to show; false to hide.
     */
    protected void setMenuItemsVisibility(boolean visible) {
        for (int i = 0; i < mMenu.size(); i++) {
            MenuItem item = mMenu.getItem(i);
            if (item != mSearchItem) {
                item.setVisible(visible);
            }
        }
    }

    /**
     * Closes the search view.  The onClose method of {@link SearchInteractionListener} is not
     * called here.
     */
    protected void iconifySearchView() {
        mSearchView.setQuery("", false);
        mSearchView.setIconified(true);
    }
    //endregion
}
