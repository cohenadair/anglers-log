package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The ListSelectionManager is a simple class that defines a subclass of
 * {@link android.support.v7.widget.RecyclerView.ViewHolder} that automatically manages selected
 * items.
 *
 * @author Cohen ADair
 */
public class ListSelectionManager {

    public static abstract class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private UUID mId;

        private Adapter mAdapter;
        private View mView;

        public ViewHolder(View view, Adapter adapter) {
            super(view);

            view.setOnClickListener(this);

            mAdapter = adapter;
            mView = view;
        }

        //region Getters & Setters
        public UUID getId() {
            return mId;
        }

        public void setId(UUID id) {
            mId = id;
        }

        public Adapter getAdapter() {
            return mAdapter;
        }

        public View getView() {
            return mView;
        }
        //endregion

        @Override
        public void onClick(View v) {
            if (mAdapter.isManagingMultipleSelections())
                addToSelections();
            else {
                updateSelection();
                finishSelection();
            }
        }

        public void setSelection(boolean select) {
            if (!mAdapter.isManagingMultipleSelections())
                return;

            getObject().setIsSelected(select);
            ViewUtils.setSelected(mView, getObject().getIsSelected());
        }

        private void addToSelections() {
            if (getObject().getIsSelected())
                mAdapter.removeSelectedItem(mId);
            else
                mAdapter.addSelectedItem(mId);

            setSelection(!getObject().getIsSelected());
        }

        /**
         * Replaces the current selection with this {@link UserDefineObject}. This is only used
         * in two-pane layouts to show item selection.
         */
        private void updateSelection() {
            if (!mAdapter.isManagingSingleSelections())
                return;

            // remove old selection
            if (mAdapter.getSelectedPosition() != -1)
                mAdapter.getItem(mAdapter.getSelectedPosition()).setIsSelected(false);

            // add new selection
            getObject().setIsSelected(true);

            // update UI
            mAdapter.setSelectedPosition(getAdapterPosition());
            mAdapter.notifyDataSetChanged();
        }

        private void finishSelection() {
            mAdapter.addSelectedItem(mId);
            mAdapter.getCallbacks().onClick(getView(), getId());
        }

        public UserDefineObject getObject() {
            return mAdapter.getItem(mId);
        }

        /**
         * This should be called in subclasses after the ViewHolder is inflated.
         */
        public void updateViews() {
            if (mAdapter.isManagingSingleSelections())
                ViewUtils.setSelected(mView, getAdapterPosition() == mAdapter.getSelectedPosition());
        }
    }

    public static abstract class Adapter extends RecyclerView.Adapter {

        private ArrayList<UUID> mSelectedIds; // ids are used to track selections to ensure we're keeping the same object references
        private ArrayList<UserDefineObject> mItems;
        private OnClickInterface mCallbacks;
        private Context mContext;
        private boolean mManagingMultipleSelections;
        private boolean mManagingSingleSelections;
        private int mSelectedPosition = -1; // used for showing selection in two-pane layouts

        /**
         * A {@link android.support.v7.widget.RecyclerView.Adapter} subclass that manages item
         * selection.  If setup so only one item can be selected, a callback method is called,
         * otherwise the selections are managed by the adapter and can be retrieved via
         * {@link #getSelectedIds()}.
         *
         * @param items The list of {@link UserDefineObject} from which to initialize the adapter.
         * @param showSingleSelection True to show single selections, false otherwise.
         * @param showMultipleSelection True to allow multiple selections, false otherwise.
         * @param callbacks Called when an item is clicked. This callback is ignored if
         *                  `allowMultipleSelection` is true.
         */
        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean showSingleSelection, boolean showMultipleSelection, OnClickInterface callbacks) {
            mItems = items;
            mManagingMultipleSelections = showMultipleSelection;
            mManagingSingleSelections = showSingleSelection;
            mCallbacks = callbacks;
            mContext = context;
            mSelectedIds = new ArrayList<>();

            // initialize selections if needed
            if (mManagingSingleSelections && !mManagingMultipleSelections)
                for (int i = 0; i < items.size(); i++)
                    if (items.get(i).getIsSelected()) {
                        mSelectedPosition = i;
                        break;
                    }
        }

        public Adapter(ArrayList<UserDefineObject> items, boolean showSingleSelection, boolean showMultipleSelection, OnClickInterface callbacks) {
            this(null, items, showSingleSelection, showMultipleSelection, callbacks);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            this(context, items, false, false, callbacks);
        }

        //region Getters & Setters
        public ArrayList<UserDefineObject> getItems() {
            return mItems;
        }

        public OnClickInterface getCallbacks() {
            return mCallbacks;
        }

        public Context getContext() {
            return mContext;
        }

        public boolean isManagingMultipleSelections() {
            return mManagingMultipleSelections;
        }

        public void setManagingMultipleSelections(boolean managingMultipleSelections) {
            mManagingMultipleSelections = managingMultipleSelections;
        }

        public boolean isManagingSingleSelections() {
            return mManagingSingleSelections;
        }

        public void setManagingSingleSelections(boolean managingSingleSelections) {
            mManagingSingleSelections = managingSingleSelections;
        }

        public int getSelectedPosition() {
            return mSelectedPosition;
        }

        public void setSelectedPosition(int selectedPosition) {
            mSelectedPosition = selectedPosition;
        }

        public ArrayList<UUID> getSelectedIds() {
            return mSelectedIds;
        }

        public void setSelectedIds(ArrayList<UUID> selectedIds) {
            // null may be passed in if there are no selected items, or the adapter isn't
            // tracking selections
            if (selectedIds != null)
                mSelectedIds = selectedIds;
        }
        //endregion

        /**
         * Must be called by subclasses in onBindViewHolder.
         */
        public void onBind(ViewHolder holder, int position) {
            UserDefineObject obj = mItems.get(position);
            holder.setId(obj.getId());
            holder.setSelection(obj.getIsSelected() || mSelectedIds.contains(obj.getId()));
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

        public UserDefineObject getItem(int position) {
            return mItems.get(position);
        }

        public UserDefineObject getItem(UUID id) {
            return UserDefineArrays.getObjectWithId(mItems, id);
        }

        public void addSelectedItem(UUID id) {
            mSelectedIds.add(id);
        }

        public void removeSelectedItem(UUID id) {
            mSelectedIds.remove(id);
        }
    }
}
