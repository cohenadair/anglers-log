package com.cohenadair.anglerslog.utilities;

import android.content.Context;
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
    public static class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private OnClickInterface mCallbacks;
        private int mItemPosition;

        public ViewHolder(View view, OnClickInterface callbacks) {
            super(view);
            view.setOnClickListener(this);
            mCallbacks = callbacks;
        }

        @Override
        public void onClick(View view) {
            if (mCallbacks != null)
                mCallbacks.onClick(view, mItemPosition);
        }

        public void setItemPosition(int itemPosition) {
            mItemPosition = itemPosition;
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
