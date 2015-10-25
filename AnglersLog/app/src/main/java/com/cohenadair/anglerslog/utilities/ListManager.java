package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
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
        private UUID mId;

        /**
         * Must be implemented by subclasses.
         * @param position The position of the item to edit or delete.
         */
        public abstract void onItemEdit(UUID position);
        public abstract void onItemDelete(UUID position);

        public ViewHolder(View view, Adapter adapter) {
            super(view);

            view.setOnClickListener(this);
            view.setOnLongClickListener(this);

            mAdapter = adapter;
        }

        @Override
        public void onClick(View view) {
            mAdapter.getCallbacks().onClick(view, mId);
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

        public void setId(UUID id) {
            mId = id;
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
