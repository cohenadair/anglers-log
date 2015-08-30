package com.cohenadair.anglerslog.fragments;


import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * A simple {@link Fragment} subclass.
 */
public class CatchFragment extends Fragment {

    private TextView speciesTextView;
    private TextView dateTextView;

    public CatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);

        View view = inflater.inflate(R.layout.fragment_catch, container, false);

        this.speciesTextView = (TextView)view.findViewById(R.id.species_text_view);
        this.dateTextView = (TextView)view.findViewById(R.id.date_text_view);

        this.updateCatch(Logbook.getSharedLogbook().getCurrentCatchPos());

        // Inflate the layout for this fragment
        return view;
    }

    public void updateCatch(int pos) {
        Catch aCatch = Logbook.getSharedLogbook().catchAtPos(pos);

        this.speciesTextView.setText(aCatch.speciesAsString());
        this.dateTextView.setText(aCatch.dateAsString());
    }

}
