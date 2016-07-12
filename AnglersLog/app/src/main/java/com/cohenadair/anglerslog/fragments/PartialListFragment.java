package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;

/**
 * A simple {@link Fragment} subclass that show a list of items. Note that
 * {@link #setAdapter(RecyclerView.Adapter)} must be called before displaying an instance of
 * {@link PartialListFragment}.
 *
 * @author Cohen Adair
 */
public class PartialListFragment extends Fragment {

    private RecyclerView.Adapter mAdapter;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_simple_list, container, false);

        RecyclerView recyclerView = (RecyclerView)view.findViewById(R.id.recycler_view);
        recyclerView.setAdapter(mAdapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.setHasFixedSize(true);

        return view;
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        mAdapter = adapter;
    }
}
