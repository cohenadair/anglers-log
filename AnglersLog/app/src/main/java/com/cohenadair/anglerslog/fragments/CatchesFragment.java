package com.cohenadair.anglerslog.fragments;

import android.app.ListFragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * A placeholder fragment containing a simple view.
 */
public class CatchesFragment extends ListFragment {

    public CatchesFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View aView = super.onCreateView(inflater, container, savedInstanceState);

        // set the list's adapter
        ArrayAdapter adapter = new ArrayAdapter<Catch>(this.getActivity(), android.R.layout.simple_list_item_1, Logbook.getSharedLogbook().getCatches());
        setListAdapter(adapter);

        return aView;
    }

    @Override
    public void onListItemClick(ListView aListView, View aView, int aPos, long id) {
        Toast.makeText(getActivity(), "Test", Toast.LENGTH_SHORT).show();
    }
}
