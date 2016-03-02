package com.cohenadair.anglerslog.interfaces;

import android.view.View;

import java.util.UUID;

/**
 * A custom OnClick interface used for RecyclerViews.
 * @author Cohen Adair
 */
public interface OnClickInterface {
    void onClick(View view, UUID id);
}
