package com.cohenadair.anglerslog.fragments;

import android.support.v4.app.Fragment;

/**
 * The DetailFragment class is meant to be extended by any "detail" fragments.
 * A detail fragment is a fragment that shows details after a user selects an item from a list view.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public abstract class DetailFragment extends Fragment {

    /**
     * The method that updates the view using the object at the corresponding ListView position.
     * @param position the position of the clicked ListItem in the master view.
     */
    public abstract void update(int position);

}
