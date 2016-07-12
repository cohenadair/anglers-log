package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.LayoutSpec;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;

import java.util.ArrayList;
import java.util.UUID;

public class MyListSelectionActivity extends LayoutSpecActivity {

    /**
     * Needed for selections such as locations, where an action is required after the initial
     * ListItemView click. If this extra is true, the initial action will be cancelled.
     */
    public static final String EXTRA_CANCEL_SELECTION_INTERFACE = "extra_cancel_selection_interface";

    public static final String EXTRA_SELECTED_IDS = "extra_selected_ids";
    public static final String EXTRA_LAYOUT_ID = "extra_layout_id";
    public static final String EXTRA_MULTIPLE_SELECTION = "extra_multiple_selection";

    private UUID mGlobalSelectedId; // save the ListManager's selection to be reset later
    private boolean mCanSelectMultiple;
    private boolean mCancelSelectionInterface;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_list_selection);

        Intent intent = getIntent();
        int layoutId = intent.getIntExtra(EXTRA_LAYOUT_ID, -1);
        mCanSelectMultiple = intent.getBooleanExtra(EXTRA_MULTIPLE_SELECTION, false);
        mCancelSelectionInterface = intent.getBooleanExtra(EXTRA_CANCEL_SELECTION_INTERFACE, false);

        setLayoutSpec(LayoutSpecManager.layoutSpec(this, layoutId));

        initDialogWidth();
        initToolbar();
        initSelections(intent);

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, getMasterFragment())
                    .commit();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_mylist_selection, menu);

        MenuItem done = menu.findItem(R.id.action_done);
        if (done != null && !mCanSelectMultiple)
            done.setVisible(false);

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_done) {
            finishWithResult();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        finish();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        setActionBarTitle("");
    }

    //region MyListFragment.InteractionListener
    @Override
    public OnClickInterface getOnMyListFragmentItemClick() {
        return new OnClickInterface() {
            @Override
            public void onClick(final View view, UUID id) {
                LayoutSpec.OnSelectionListener listener = getLayoutSpec().getSelectionListener();

                if (listener != null && !mCancelSelectionInterface)
                    listener.onSelect(id, new LayoutSpec.OnSelectionFinishedCallback() {
                        @Override
                        public void onFinish(UUID id) {
                            ArrayList<String> selectedIds = new ArrayList<>();
                            selectedIds.add(id.toString());
                            finishWithResult(selectedIds);
                        }
                    });
                else
                    finishWithResult();
            }
        };
    }

    @Override
    public boolean isSelecting() {
        return true;
    }

    @Override
    public boolean isSelectingMultiple() {
        return mCanSelectMultiple;
    }
    //endregion

    @Override
    public void initToolbar() {
        super.initToolbar();

        if (isTwoPane()) {
            ViewUtils.setVisibility(getToolbar(), mCanSelectMultiple);
            ViewUtils.addDoneButton(getToolbar(), new MenuItem.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    finishWithResult();
                    return true;
                }
            });
        }
    }

    @Override
    public void goToListManagerView() {
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.container, getManageFragment())
                .addToBackStack(null)
                .commit();

        setActionBarTitle(getViewTitle());
    }

    @Override
    public void goBack() {
        getSupportFragmentManager().popBackStack();
        setActionBarTitle("");
    }

    private void finishWithResult() {
        finishWithResult(UserDefineArrays.idsAsStrings(getMasterAdapter().getSelectedIds()));
    }

    private void finishWithResult(ArrayList<String> selectedIds) {
        Intent intent = new Intent();
        intent.putExtra(EXTRA_SELECTED_IDS, selectedIds);
        setResult(RESULT_OK, intent);
        releaseSelections();
        finish();
    }

    private void initSelections(Intent intent) {
        ListManager.Adapter adapter = getMasterAdapter();
        adapter.setManagingMultipleSelections(mCanSelectMultiple);

        // get the globally selected item (one that's shown in master-detail view)
        // so it can be reset later
        for (UserDefineObject obj : adapter.getItems())
            if (obj.getIsSelected()) {
                mGlobalSelectedId = obj.getId();
                obj.setIsSelected(false);
            }

        ArrayList<String> selectedIdStrings = intent.getStringArrayListExtra(EXTRA_SELECTED_IDS);
        adapter.setSelectedIds(UserDefineArrays.stringsAsIds(selectedIdStrings));
    }

    private void releaseSelections() {
        if (mGlobalSelectedId != null)
            getMasterAdapter().getItem(mGlobalSelectedId).setIsSelected(true);
    }
}
