package com.cohenadair.anglerslog.fragments;

import android.app.Activity;
import android.app.ListFragment;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * The fragment showing the list of catches.
 */
public class CatchesFragment extends ListFragment {

    //region Callback Interface
    OnListItemSelectedListener callback;

    // callback interface for the fragment's activity
    public interface OnListItemSelectedListener {
        void onCatchSelected(int pos);
    }
    //endregion

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
        this.callback.onCatchSelected(pos);
    }

    @Override
    public void onAttach(Activity anActivity) {
        super.onAttach(anActivity);

        // make sure the container activity has implemented the callback interface
        try {
            this.callback = (OnListItemSelectedListener)anActivity;
        } catch (ClassCastException e) {
            throw new ClassCastException(anActivity.toString() + " must implement OnListItemSelectedListener");
        }
    }
}
