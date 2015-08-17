package com.cohenadair.anglerslog.fragments;

import android.app.ListFragment;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * The fragment showing the list of catches.
 */
public class CatchesFragment extends ListFragment {

    public CatchesFragment() {

    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View aView = super.onCreateView(inflater, container, savedInstanceState);

        // set the list's adapter
        ArrayAdapter adapter = new ArrayAdapter<Catch>(this.getActivity(), android.R.layout.simple_list_item_1, Logbook.getSharedLogbook().getCatches());
        setListAdapter(adapter);

        return aView;
    }

    @Override
    public void onListItemClick(ListView listView, View view, int pos, long id) {
        Toast.makeText(getActivity(), "Test", Toast.LENGTH_SHORT).show();
        Log.d("onListItemClick", "Clicked item!");
    }
}
