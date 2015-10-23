package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;

/**
 * The ListManager is a utility class for managing the catches list. This class should never be
 * instantiated. Only the ViewHolder and Adapter classes should be used.
 * Created by Cohen Adair on 2015-10-05.
 */
public class ListManager {

    //region View Holder
    public static abstract class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener, View.OnLongClickListener {

        private Adapter mAdapter;
        private int mItemPosition;

        /**
         * Must be implemented by subclasses.
         * @param position The position of the item to edit or delete.
         */
        public abstract void onItemEdit(int position);
        public abstract void onItemDelete(int position);

        public ViewHolder(View view, Adapter adapter) {
            super(view);

            view.setOnClickListener(this);
            view.setOnLongClickListener(this);

            mAdapter = adapter;
        }

        @Override
        public void onClick(View view) {
            mAdapter.getCallbacks().onClick(view, mItemPosition);
        }

        @Override
        public boolean onLongClick(View view) {
            UserDefineObject obj = mAdapter.itemAtPos(mItemPosition);

            Utils.showManageAlert(mAdapter.getContext(), obj.displayName(), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    switch (which) {
                        case Utils.MANAGE_ALERT_EDIT:
                            onItemEdit(mItemPosition);
                            break;

                        case Utils.MANAGE_ALERT_DELETE:
                            onItemDelete(mItemPosition);
                            break;
                    }
                }
            });
            return true;
        }

        public void setItemPosition(int itemPosition) {
            mItemPosition = itemPosition;
        }

        public Adapter getAdapter() {
            return mAdapter;
        }

        public Context context() {
            return mAdapter.getContext();
        }
    }
    //endregion

    //region Adapter
    public static abstract class Adapter extends RecyclerView.Adapter<ViewHolder> {

        private OnClickInterface mCallbacks;
        private Context mContext;
        private ArrayList<UserDefineObject> mItems;

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            mContext = context;
            mItems = items;
            mCallbacks = callbacks;
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

        public void onBind(ViewHolder holder, int position) {
            holder.setItemPosition(position);
        }

        public OnClickInterface getCallbacks() {
            return mCallbacks;
        }

        public Context getContext() {
            return mContext;
        }

        public UserDefineObject itemAtPos(int position) {
            return mItems.get(position);
        }
    }
    //endregion

}
