package com.cohenadair.anglerslog.fragments;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * A placeholder fragment containing a simple view.
 */
public class CatchesFragment extends Fragment {

    public CatchesFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View aView = inflater.inflate(R.layout.fragment_catches, container, false);

        // set the list's adapter
        ArrayAdapter adapter = new ArrayAdapter<Catch>(this.getActivity(), android.R.layout.simple_list_item_1, Logbook.getSharedLogbook().getCatches());
        ListView listView = (ListView)aView.findViewById(R.id.allCatchesListView);
        listView.setAdapter(adapter);

        return aView;
    }
}
