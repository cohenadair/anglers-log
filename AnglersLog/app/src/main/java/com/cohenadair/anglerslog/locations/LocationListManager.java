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

        LocationListManager.Adapter.GetContentListener mListener;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);
            mListener = ((LocationListManager.Adapter)getAdapter()).getGetContentListener();
            initForSimpleLayout();
        }

        public void setLocation(Location location) {
            setTitle(location.getName());
            int suffixId;

            if (mListener != null) {
                setSubtitle(mListener.onGetSubtitle(location));
            } else {
                suffixId = location.getFishingSpotCount() == 1 ? R.string.fishing_spot : R.string.fishing_spots;
                setSubtitle(String.format("%d " + getContext().getResources().getString(suffixId), location.getFishingSpotCount()));
            }

            // hide sub-subtitle if in condensed layout
            if (!getAdapter().isCondensed()) {
                suffixId = location.getFishCaughtCount() == 1 ? R.string.catch_string : R.string.drawer_catches;
                setSubSubtitle(String.format("%d " + getContext().getResources().getString(suffixId), location.getFishCaughtCount()));
            }

            updateViews();
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        private GetContentListener mGetContentListener;

        /**
         * Used for non-default subtitle text.
         */
        public interface GetContentListener {
            String onGetSubtitle(Location location);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean singleSelection, boolean multiSelection, OnClickInterface callbacks) {
            super(context, items, singleSelection, multiSelection, callbacks);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean condensed, OnClickInterface callbacks, GetContentListener getContentListener) {
            super(context, items, condensed, callbacks);
            mGetContentListener = getContentListener;
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, false, false, callbacks);
        }

        public GetContentListener getGetContentListener() {
            return mGetContentListener;
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
