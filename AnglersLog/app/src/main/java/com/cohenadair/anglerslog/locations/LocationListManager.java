package com.cohenadair.anglerslog.locations;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;

import java.util.ArrayList;

/**
 * The LocationListManager is a utility class for managing the locations list.
 * Created by Cohen Adair on 2015-12-06.
 */
public class LocationListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ListManager.Adapter mAdapter;
        private TextView mNameTextView;
        private TextView mNumberSpotsTextView;
        private View mSeparator;
        private View mView;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mAdapter = adapter;
            mView = view;
            mNameTextView = (TextView)view.findViewById(R.id.location_name_text_view);
            mNumberSpotsTextView = (TextView)view.findViewById(R.id.spots_text_view);
            mSeparator = view.findViewById(R.id.cell_separator);
        }

        public void setLocation(Location location, int position) {
            mNameTextView.setText(location.getName());
            mNumberSpotsTextView.setText(String.format("%d " + context().getResources().getString(R.string.fishing_spots), location.getFishingSpotCount()));

            // hide the separator for the last row
            mSeparator.setVisibility((position == mAdapter.getItemCount() - 1) ? View.INVISIBLE : View.VISIBLE);
            mView.setBackgroundResource(location.isSelected() ? R.color.light_grey : android.R.color.transparent);
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
            View view = inflater.inflate(R.layout.list_item_location, parent, false);
            return new ViewHolder(view, this);
        }

        @Override
        public void onBindViewHolder(ListManager.ViewHolder holder, int position) {
            super.onBind(holder, position);
            ((ViewHolder)holder).setLocation((Location) getItem(position), position);
        }
    }
    //endregion

}
