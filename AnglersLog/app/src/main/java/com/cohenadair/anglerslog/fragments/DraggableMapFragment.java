package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.utilities.GoogleMapLayout;
import com.google.android.gms.maps.SupportMapFragment;

/**
 * A SupportMapFragment wrapper class to handle map drag events.
 * Created by Cohen Adair on 2015-12-06.
 */
public class DraggableMapFragment extends SupportMapFragment {

    private View mOriginalView;
    private GoogleMapLayout mMapLayout;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mOriginalView = super.onCreateView(inflater, container, savedInstanceState);

        mMapLayout = new GoogleMapLayout(getActivity());
        mMapLayout.addView(mOriginalView);

        return mMapLayout;
    }

    @Override
    public View getView() {
        return mOriginalView;
    }

    public void setOnDragListener(GoogleMapLayout.OnDragListener onDragListener) {
        mMapLayout.setOnDragListener(onDragListener);
    }
}
