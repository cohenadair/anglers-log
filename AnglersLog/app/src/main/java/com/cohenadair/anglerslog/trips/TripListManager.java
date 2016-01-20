package com.cohenadair.anglerslog.trips;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

/**
 * The TripListManager is a utility class for managing the trips list.
 * Created by Cohen Adair on 2016-01-20.
 */
public class TripListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ListManager.Adapter mAdapter;
        private View mSeparator;
        private View mView;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);
        }

        public void setTrip(Trip trip, int position) {
            // hide the separator for the last row
            mSeparator.setVisibility((position == mAdapter.getItemCount() - 1) ? View.INVISIBLE : View.VISIBLE);
            Utils.toggleViewSelected(mView, trip.getIsSelected());
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, callbacks);
        }

        // can't be overridden in the superclass because it needs to return a BaitListManager.ViewHolder
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            View view = inflater.inflate(R.layout.list_item_trip, parent, false);
            return new ViewHolder(view, this);
        }

        @Override
        public void onBindViewHolder(ListManager.ViewHolder holder, int position) {
            super.onBind(holder, position);
            ((ViewHolder)holder).setTrip((Trip)getItem(position), position);
        }
    }
    //endregion

}
