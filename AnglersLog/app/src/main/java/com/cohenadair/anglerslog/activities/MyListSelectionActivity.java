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
import com.cohenadair.anglerslog.utilities.LayoutSpec;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;

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

    private ArrayList<String> mSelectedIds;
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
        getMenuInflater().inflate(R.menu.menu_my_list_selection, menu);

        MenuItem done = menu.findItem(R.id.action_done);
        if (done != null && !mCanSelectMultiple)
            done.setVisible(false);

        initMenu(menu);

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
                            handleItemSelection(view, id);
                        }
                    });
                else
                    handleItemSelection(view, id);
            }
        };
    }

    @Override
    public void initToolbar() {
        super.initToolbar();

        if (isTwoPane()) {
            Utils.toggleVisibility(getToolbar(), mCanSelectMultiple);
            Utils.addDoneButton(getToolbar(), new MenuItem.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    finishWithResult();
                    return true;
                }
            });
        }
    }

    /**
     * Processes the given id when selected or deselected.
     * @param id The UUID of the item selected or deselected.
     */
    private void handleItemSelection(View view, UUID id) {
        String idStr = id.toString();

        if (mCanSelectMultiple) {
            boolean alreadySelected = mSelectedIds.contains(idStr);

            if (alreadySelected)
                mSelectedIds.remove(idStr);
            else
                mSelectedIds.add(idStr);

            Utils.toggleViewSelected(view, !alreadySelected);
        } else {
            mSelectedIds.add(idStr);
            finishWithResult();
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
        Intent intent = new Intent();
        intent.putExtra(EXTRA_SELECTED_IDS, mSelectedIds);
        setResult(RESULT_OK, intent);
        releaseSelections();
        finish();
    }

    private void initSelections(Intent intent) {
        ListManager.Adapter adapter = getMasterAdapter();
        adapter.setShowSelection(false);

        // get the globally selected item (one that's shown in master-detail view)
        // so it can be reset later
        for (int i = 0; i < adapter.getItemCount(); i++)
            if (adapter.getItem(i).getIsSelected()) {
                mGlobalSelectedId = adapter.getItem(i).getId();
                adapter.getItem(i).setIsSelected(false);
                break;
            }

        mSelectedIds = intent.getStringArrayListExtra(EXTRA_SELECTED_IDS);
        if (mSelectedIds == null)
            mSelectedIds = new ArrayList<>();

        toggleSelections(true);
    }

    private void releaseSelections() {
        toggleSelections(false);

        // reset all item selections
        if (mGlobalSelectedId != null) {
            ListManager.Adapter adapter = getMasterAdapter();
            for (int i = 0; i < adapter.getItemCount(); i++) {
                UserDefineObject item = adapter.getItem(i);
                item.setIsSelected(item.getId().equals(mGlobalSelectedId));
            }
        }
    }

    /**
     * Toggles the selection of all items in the selected id array.
     * @param selected True selects, false deselects.
     */
    private void toggleSelections(boolean selected) {
        ListManager.Adapter adapter = getMasterAdapter();
        for (String idStr : mSelectedIds) {
            UserDefineObject object = adapter.getItem(UUID.fromString(idStr));
            if (object != null)
                object.setIsSelected(selected);
        }
    }

    @Override
    public void setMenuItemsVisibility(boolean visible) {
        for (int i = 0; i < getMenu().size(); i++) {
            MenuItem item = getMenu().getItem(i);
            int itemId = item.getItemId();

            if (item != getSearchItem() && itemId != R.id.action_done)
                item.setVisible(visible);

            // only handle the done button if it's applicable to this instance
            if (itemId == R.id.action_done && mCanSelectMultiple)
                item.setVisible(visible);
        }
    }
}
