package com.cohenadair.anglerslog.locations;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;

import java.util.ArrayList;

/**
 * The LocationListManager is a utility class for managing the locations list.
 * @author Cohen Adair
 */
public class LocationListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);
            initForSimpleLayout();
        }

        public void setLocation(Location location) {
            setTitle(location.getName());

            int suffixId = location.getFishingSpotCount() == 1 ? R.string.fishing_spot : R.string.fishing_spots;
            setSubtitle(String.format("%d " + getContext().getResources().getString(suffixId), location.getFishingSpotCount()));

            suffixId = location.getCatchCount() == 1 ? R.string.catch_string : R.string.drawer_catches;
            setSubSubtitle(String.format("%d " + getContext().getResources().getString(suffixId), location.getCatchCount()));
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
            return new ViewHolder(inflateComplexItem(parent), this);
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            ViewHolder locationHolder = (ViewHolder)holder;

            super.onBind(locationHolder, position);
            locationHolder.setLocation((Location) getItem(position));
        }
    }
    //endregion

}
