package com.cohenadair.anglerslog.fragments;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;
import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.FragmentUtils;

/**
 * A simple {@link Fragment} subclass.
 */
public class CatchFragment extends DetailFragment {

    public static final String TAG = "catch_fragment";

    private TextView mSpeciesTextView;
    private TextView mDateTextView;

    public CatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catch, container, false);

        mSpeciesTextView = (TextView)view.findViewById(R.id.species_text_view);
        mDateTextView = (TextView)view.findViewById(R.id.date_text_view);

        if (Logbook.getInstance().catchCount() <= 0) {
            mSpeciesTextView.setText("There are 0 catches in your log.");
            mDateTextView.setText("");
        } else
            update(Logbook.getInstance().getCurrentCatchPos());

        MainActivity activity = (MainActivity)getActivity();

        // apply required LayoutParams for two-pane layout
        if (activity.isTwoPane())
            view.setLayoutParams(FragmentUtils.standardLayoutParams(getResources(), R.dimen.right_panel_weight));

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(int pos) {
        Catch aCatch = Logbook.getInstance().catchAtPos(pos);

        mSpeciesTextView.setText(aCatch.speciesAsString());
        mDateTextView.setText(aCatch.dateAsString());
    }

}
