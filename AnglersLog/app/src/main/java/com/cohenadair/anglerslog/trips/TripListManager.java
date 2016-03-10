package com.cohenadair.anglerslog.trips;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;

/**
 * The TripListManager is a utility class for managing the trips list.
 * Created by Cohen Adair on 2016-01-20.
 */
public class TripListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private TitleSubTitleView mTitleSubTitleView;
        private View mSeparator;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mTitleSubTitleView = (TitleSubTitleView)view.findViewById(R.id.title_subtitle_view);
            mSeparator = view.findViewById(R.id.separator);
        }

        public void setTrip(Trip trip, int position) {
            if (trip.isNameNull())
                mTitleSubTitleView.hideSubtitle();

            String dateString = trip.getDateAsString(getContext());
            mTitleSubTitleView.setTitle(trip.isNameNull() ? dateString : trip.getName());
            mTitleSubTitleView.setSubtitle(dateString);
            mTitleSubTitleView.setSubSubtitle(trip.getCatchesAsString(getContext()));

            updateView(mSeparator, position);
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean allowMultipleSelection, OnClickInterface callbacks) {
            super(context, items, allowMultipleSelection, callbacks);
        }

        // can't be overridden in the superclass because it needs to return a BaitListManager.ViewHolder
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            View view = inflater.inflate(R.layout.list_item_trip, parent, false);
            return new ViewHolder(view, this);
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            ViewHolder tripHolder = (ViewHolder)holder;

            super.onBind(tripHolder, position);
            tripHolder.setTrip((Trip) getItem(position), position);
        }
    }
    //endregion

}
