package com.cohenadair.anglerslog.trips;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;

import java.util.ArrayList;

/**
 * The TripListManager is a utility class for managing the trips list.
 * Created by Cohen Adair on 2016-01-20.
 */
public class TripListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ListManager.Adapter mAdapter;
        private TextView mNameTextView;
        private TextView mDateTextView;
        private TextView mCatchesTextView;
        private View mSeparator;
        private View mView;
        private Context mContext;

        public ViewHolder(View view, ListManager.Adapter adapter, Context context) {
            super(view, adapter);

            mAdapter = adapter;
            mView = view;
            mContext = context;

            mNameTextView = (TextView)view.findViewById(R.id.name_text_view);
            mDateTextView = (TextView)view.findViewById(R.id.dates_text_view);
            mCatchesTextView = (TextView)view.findViewById(R.id.catches_text_view);
            mSeparator = view.findViewById(R.id.separator);
        }

        public void setTrip(Trip trip, int position) {
            if (trip.isNameNull())
                mDateTextView.setVisibility(View.GONE);

            String dateString = trip.getDateAsString(mContext);
            mNameTextView.setText(trip.isNameNull() ? dateString : trip.getName());
            mDateTextView.setText(dateString);
            mCatchesTextView.setText(trip.getCatchesAsString(mContext));

            updateView(mSeparator, position, trip);
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        private Context mContext;

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, callbacks);
            mContext = context;
        }

        // can't be overridden in the superclass because it needs to return a BaitListManager.ViewHolder
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            View view = inflater.inflate(R.layout.list_item_trip, parent, false);
            return new ViewHolder(view, this, mContext);
        }

        @Override
        public void onBindViewHolder(ListManager.ViewHolder holder, int position) {
            super.onBind(holder, position);
            ((ViewHolder)holder).setTrip((Trip)getItem(position), position);
        }
    }
    //endregion

}
