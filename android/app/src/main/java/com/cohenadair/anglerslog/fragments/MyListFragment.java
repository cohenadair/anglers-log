package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.utilities.SortingMethod;
import com.cohenadair.anglerslog.model.utilities.SortingUtils;
import com.cohenadair.anglerslog.utilities.LayoutSpec;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.views.BottomSheetView;

/**
 * A {@link MasterFragment} subclass that displays a list of items, such as
 * {@link com.cohenadair.anglerslog.model.user_defines.Catch} or
 * {@link com.cohenadair.anglerslog.model.user_defines.Bait} objects.
 *
 * @author Cohen Adair
 */
public class MyListFragment extends MasterFragment {

    private RecyclerView mRecyclerView;

    /**
     * Used to manage the App Bar's menu, including preserving search queries and the SearchView
     * through Fragment transactions.
     */
    private Menu mMenu;
    private MenuItem mSearchItem;
    private SearchView mSearchView;
    private String mSearchText = "";
    private boolean mSearchIsExpanded = false;

    //region Callback Interface
    InteractionListener mCallbacks;

    /**
     * Callback interface must be implemented by any Activity implementing MyListFragment.
     */
    public interface InteractionListener {
        LayoutSpec getLayoutSpec();

        void updateViews();
        void updateViews(String searchQuery);
        void updateViews(SortingMethod sortingMethod);

        boolean isSelecting();
        boolean isSelectingMultiple();
        boolean isTwoPane();

        void onMyListClickNewButton();
    }
    //endregion

    public MyListFragment() {
        // default constructor required
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_mylist, container, false);

        initNewButton(view);
        initRecyclerView(view);
        initBottomSheets(view);

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (InteractionListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement MyListFragment.InteractionListener.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_mylist, menu);
        mMenu = menu;
        initSearch();
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_sort) {
            openSortDialog();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void updateInterface() {
        if (mRecyclerView != null && mRecyclerView.getAdapter() != null) {
            // rather than always resetting adapter, just refresh
            // this avoids slight lag in navigation
            if (mRecyclerView.getAdapter() != getLayoutSpec().getMasterAdapter())
                mRecyclerView.setAdapter(getLayoutSpec().getMasterAdapter());
            else
                mRecyclerView.getAdapter().notifyDataSetChanged();
        }
    }

    private LayoutSpec getLayoutSpec() {
        return mCallbacks.getLayoutSpec();
    }

    //region View Initializing
    private void initRecyclerView(View view) {
        mRecyclerView = (RecyclerView)view.findViewById(R.id.main_recycler_view);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        mRecyclerView.setAdapter(getLayoutSpec().getMasterAdapter());
    }

    private void initNewButton(View view) {
        FloatingActionButton newButton = (FloatingActionButton)view.findViewById(R.id.new_button);
        newButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onMyListClickNewButton();
            }
        });
    }

    private void initBottomSheets(View view) {
        final BottomSheetView bugsBottomSheet = (BottomSheetView)view.findViewById(R.id.instabug_bottom_sheet_view);
        final BottomSheetView backupSheetView = (BottomSheetView)view.findViewById(R.id.backup_bottom_sheet_view);

        if (LogbookPreferences.shouldShowInstabugSheet()) {
            bugsBottomSheet.init(
                    bugsBottomSheet,
                    R.drawable.instabug_ic_ibg_logo_dark,
                    R.string.instabug_sheet_title,
                    R.string.instabug_sheet_description,
                    R.string.dismiss,
                    true,
                    new BottomSheetView.InteractionListener() {
                        @Override
                        public void onDismiss() {
                            LogbookPreferences.setShouldShowInstabugSheet(false);
                        }
                    }
            );
        } else {
            // just a precaution if it happens to be showing
            bugsBottomSheet.setVisibility(View.GONE);
        }

        if (LogbookPreferences.shouldShowBackupSheet()) {
            backupSheetView.init(
                    backupSheetView,
                    R.drawable.ic_info,
                    R.string.backup_sheet_title,
                    R.string.backup_sheet_description,
                    R.string.dismiss,
                    true,
                    new BottomSheetView.InteractionListener() {
                        @Override
                        public void onDismiss() {
                            LogbookPreferences.updateLastBackup();
                        }
                    }
            );
        } else {
            // just a precaution if it happens to be showing
            backupSheetView.setVisibility(View.GONE);
        }
    }
    //endregion

    //region Sorting
    public void openSortDialog() {
        new AlertDialog.Builder(getActivity())
                .setTitle(getResources().getString(R.string.sort_by))
                .setPositiveButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setItems(SortingUtils.getDialogOptions(getLayoutSpec().getSortingMethods()), getOnSortMethodSelected())
                .show();
    }

    public DialogInterface.OnClickListener getOnSortMethodSelected() {
        return new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                mCallbacks.updateViews(getLayoutSpec().getSortingMethods()[which]);
            }
        };
    }
    //endregion

    //region Searching
    public void initSearch() {
        mSearchItem = mMenu.findItem(R.id.action_search);

        mSearchView = (SearchView) mSearchItem.getActionView();
        mSearchView.setIconified(!mSearchIsExpanded);
        mSearchView.setOnSearchClickListener(getOnSearchClickListener());
        mSearchView.setOnCloseListener(getOnSearchCloseListener());
        mSearchView.setOnQueryTextListener(getOnQueryTextListener());

        if (mSearchIsExpanded)
            mSearchView.setQuery(mSearchText, true);

        setMenuItemsVisibility(!mSearchIsExpanded);
    }

    public void resetSearch() {
        mSearchText = "";
        mSearchIsExpanded = false;
        mSearchView.setQuery("", false);
        mCallbacks.updateViews();
    }

    @NonNull
    private SearchView.OnClickListener getOnSearchClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mCallbacks.isTwoPane())
                    setMenuItemsVisibility(false);

                // update hint
                String search = getResources().getString(R.string.search);
                mSearchView.setQueryHint(search + " " + getLayoutSpec().getPluralName().toLowerCase());
                mSearchIsExpanded = true;
            }
        };
    }

    @NonNull
    private SearchView.OnCloseListener getOnSearchCloseListener() {
        return new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                setMenuItemsVisibility(true);
                resetSearch();

                // returning false will "iconify" the SearchView
                return false;
            }
        };
    }

    @NonNull
    private SearchView.OnQueryTextListener getOnQueryTextListener() {
        return new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                mCallbacks.updateViews(query);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                mSearchText = newText;

                if (newText.isEmpty())
                    mCallbacks.updateViews();

                return false;
            }
        };
    }
    //endregion

    /**
     * Hides or shows all menu icons.
     * @param visible True to show; false to hide.
     */
    public void setMenuItemsVisibility(boolean visible) {
        for (int i = 0; i < mMenu.size(); i++) {
            MenuItem item = mMenu.getItem(i);
            if (item != mSearchItem)
                item.setVisible(visible);
        }

        // separately handle the done button for item selection
        // this is done because it needs a couple extra conditions
        MenuItem done = mMenu.findItem(R.id.action_done);
        if (done != null)
            done.setVisible(visible && mCallbacks.isSelecting() && mCallbacks.isSelectingMultiple());
    }
}
