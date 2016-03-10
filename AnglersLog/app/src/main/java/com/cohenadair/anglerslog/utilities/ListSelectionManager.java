package com.cohenadair.anglerslog.utilities;

import android.support.v7.widget.RecyclerView;
import android.view.View;

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
            if (mAdapter.isManagingSelections())
                addToSelections();
            else
                finishSelection();
        }

        public void setSelection(boolean select) {
            if (!mAdapter.isManagingSelections())
                return;

            getObject().setIsSelected(select);
            Utils.toggleViewSelected(mView, getObject().getIsSelected());
        }

        private void addToSelections() {
            if (getObject().getIsSelected())
                mAdapter.removeSelectedItem(mId);
            else
                mAdapter.addSelectedItem(mId);

            setSelection(!getObject().getIsSelected());
        }

        private void finishSelection() {
            mAdapter.addSelectedItem(mId);
            mAdapter.getCallbacks().onSelectionFinished();
        }

        private UserDefineObject getObject() {
            return mAdapter.getItem(mId);
        }
    }

    public static abstract class Adapter extends RecyclerView.Adapter {

        private ArrayList<UUID> mSelectedIds;
        private ArrayList<UserDefineObject> mItems;
        private InteractionListener mCallbacks;
        private boolean mManagingSelections;

        public interface InteractionListener {
            void onSelectionFinished();
        }

        public Adapter(ArrayList<UserDefineObject> items, boolean manageSelections, InteractionListener callbacks) {
            mItems = items;
            mManagingSelections = manageSelections;
            mCallbacks = callbacks;
        }

        //region Getters & Setters
        public ArrayList<UserDefineObject> getSelectedItems() {
            ArrayList<UserDefineObject> result = new ArrayList<>();

            for (UUID id : mSelectedIds) {
                UserDefineObject obj = UserDefineArrays.getObjectWithId(mItems, id);
                if (obj != null)
                    result.add(obj);
            }

            return result;
        }

        public void setSelectedItems(ArrayList<UserDefineObject> selectedItems) {
            mSelectedIds = new ArrayList<>();

            if (selectedItems != null)
                for (UserDefineObject obj : selectedItems) {
                    getItem(obj.getId()).setIsSelected(true);
                    addSelectedItem(obj.getId());
                }
        }

        public ArrayList<UserDefineObject> getItems() {
            return mItems;
        }

        public InteractionListener getCallbacks() {
            return mCallbacks;
        }

        public boolean isManagingSelections() {
            return mManagingSelections;
        }
        //endregion

        /**
         * Must be called by subclasses in onBindViewHolder.
         */
        public void onBind(ViewHolder holder, int position) {
            UserDefineObject obj = mItems.get(position);
            holder.setId(obj.getId());
            holder.setSelection(obj.getIsSelected());
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
