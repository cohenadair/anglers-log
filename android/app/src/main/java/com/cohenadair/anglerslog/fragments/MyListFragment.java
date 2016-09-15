package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
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
        initBackupBottomSheet(view);
        initInstabugAlert();
        setSearchInteractionListener(getSearchInteractionListener());

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

    private void initInstabugAlert() {
        if (LogbookPreferences.shouldShowInstabugSheet()) {
            new AlertDialog.Builder(getContext())
                    .setIcon(R.drawable.instabug_ic_ibg_logo_dark)
                    .setTitle(R.string.instabug_sheet_title)
                    .setMessage(R.string.instabug_sheet_description)
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                            LogbookPreferences.setShouldShowInstabugSheet(false);
                        }
                    })
                    .show();
        }
    }

    private void initBackupBottomSheet(View view) {
        final BottomSheetView backupSheetView =
                (BottomSheetView)view.findViewById(R.id.backup_bottom_sheet_view);

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
    private SearchInteractionListener getSearchInteractionListener() {
        return new SearchInteractionListener() {
            @Override
            public void onIconClicked() {
                if (!mCallbacks.isTwoPane()) {
                    setMenuItemsVisibility(false);
                }

                // update hint
                setSearchQueryHint(String.format(getString(R.string.search),
                        getLayoutSpec().getPluralName().toLowerCase()));
            }

            @Override
            public void onClose() {

            }

            @Override
            public void onTextSubmit(String query) {
                mCallbacks.updateViews(query);
            }

            @Override
            public void onTextChanged(String newText) {
                if (newText.isEmpty()) {
                    mCallbacks.updateViews();
                }
            }

            @Override
            public void onReset() {
                mCallbacks.updateViews();
            }
        };
    }
    //endregion

    /**
     * Hides or shows all menu icons.
     * @param visible True to show; false to hide.
     */
    @Override
    public void setMenuItemsVisibility(boolean visible) {
        super.setMenuItemsVisibility(visible);

        // separately handle the done button for item selection
        // this is done because it needs a couple extra conditions
        MenuItem done = getMenu().findItem(R.id.action_done);
        if (done != null)
            done.setVisible(visible && mCallbacks.isSelecting() && mCallbacks.isSelectingMultiple());
    }
}
