package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The ListManager is a utility class for managing the catches list. This class should never be
 * instantiated. Only the ViewHolder and Adapter classes should be used.
 * Created by Cohen Adair on 2015-10-05.
 */
public class ListManager {

    //region View Holder
    public static abstract class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener, View.OnLongClickListener {

        private Adapter mAdapter;
        private View mView;
        private UUID mId;

        public ViewHolder(View view, Adapter adapter) {
            super(view);

            view.setOnClickListener(this);
            view.setOnLongClickListener(this);

            mAdapter = adapter;
            mView = view;
        }

        @Override
        public void onClick(View view) {
            mAdapter.getCallbacks().onClick(view, mId);
            mAdapter.setSelected(getAdapterPosition());
        }

        @Override
        public boolean onLongClick(View view) {
            UserDefineObject obj = mAdapter.getItem(mId);

            Utils.showManageAlert(mAdapter.getContext(), obj.getName(), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    switch (which) {
                        case Utils.MANAGE_ALERT_EDIT:
                            onItemEdit(mId);
                            break;

                        case Utils.MANAGE_ALERT_DELETE:
                            onItemDelete(mId);
                            break;
                    }
                }
            });

            return true;
        }

        public void onItemEdit(UUID position) {
            ((OnClickManageMenuListener)context()).onClickMenuEdit(position);
        }

        public void onItemDelete(UUID position) {
            ((OnClickManageMenuListener)context()).onClickMenuTrash(position);
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

        public Context context() {
            return mAdapter.getContext();
        }

        public void updateView(View separator, int position, UserDefineObject object) {
            // hide the separator for the last row
            separator.setVisibility((position == mAdapter.getItemCount() - 1) ? View.INVISIBLE : View.VISIBLE);
            Utils.toggleViewSelected(mView, object.getIsSelected() && LogbookPreferences.getIsRootTwoPane());
        }
    }
    //endregion

    //region Adapter
    public static abstract class Adapter extends RecyclerView.Adapter<ViewHolder> {

        private OnClickInterface mCallbacks;
        private Context mContext;
        private ArrayList<UserDefineObject> mItems;
        private boolean mShowSelection = true; // used for Trip's Catch and Location selection

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            mContext = context;
            mItems = items;
            mCallbacks = callbacks;
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

        public void setSelected(int position) {
            // selection visuals only apply in two-pane view
            if (!LogbookPreferences.getIsRootTwoPane() || !mShowSelection)
                return;

            for (UserDefineObject obj : mItems)
                obj.setIsSelected(false);

            mItems.get(position).setIsSelected(true);
            notifyDataSetChanged();
        }

        public void setShowSelection(boolean showSelection) {
            mShowSelection = showSelection;
        }

        public void onBind(ViewHolder holder, int position) {
            holder.setId(mItems.get(position).getId());
        }

        public OnClickInterface getCallbacks() {
            return mCallbacks;
        }

        public Context getContext() {
            return mContext;
        }

        public UserDefineObject getItem(UUID id) {
            for (UserDefineObject obj : mItems)
                if (obj.getId().equals(id))
                    return obj;

            return null;
        }

        public UserDefineObject getItem(int position) {
            return mItems.get(position);
        }
    }
    //endregion

}
