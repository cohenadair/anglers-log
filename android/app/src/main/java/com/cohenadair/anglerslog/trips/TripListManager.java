package com.cohenadair.anglerslog.trips;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;

import java.util.ArrayList;

/**
 * The TripListManager is a utility class for managing the trips list.
 * @author Cohen Adair
 */
public class TripListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);
            initForSimpleLayout();
        }

        public void setTrip(Trip trip) {
            if (trip.isNameNull())
                getTitleSubTitleView().hideSubtitle();

            String dateString = trip.getDateAsString(getContext());
            setTitle(trip.isNameNull() ? dateString : trip.getName());
            setSubtitle(dateString);
            setSubSubtitle(trip.getCatchesAsString(getContext()));

            updateViews();
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean singleSelection, boolean multiSelection, OnClickInterface callbacks) {
            super(context, items, singleSelection, multiSelection, callbacks);
        }

        // can't be overridden in the superclass because it needs to return a BaitListManager.ViewHolder
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            return new ViewHolder(inflateComplexItem(parent), this);
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            ViewHolder tripHolder = (ViewHolder)holder;

            super.onBind(tripHolder, position);
            tripHolder.setTrip((Trip) getItem(position));
        }
    }
    //endregion

}
