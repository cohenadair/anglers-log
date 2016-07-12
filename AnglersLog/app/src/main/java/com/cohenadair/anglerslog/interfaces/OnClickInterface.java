package com.cohenadair.anglerslog.interfaces;

import android.view.View;

import java.util.UUID;

/**
 * A custom OnClick interface used primarily for
 * {@link com.cohenadair.anglerslog.fragments.MyListFragment} instances.
 *
 * @author Cohen Adair
 */
public interface OnClickInterface {
    void onClick(View view, UUID id);
}
