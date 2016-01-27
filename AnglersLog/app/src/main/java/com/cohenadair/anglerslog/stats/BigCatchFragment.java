package com.cohenadair.anglerslog.stats;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;

/**
 * The BigCatchFragment is a statistical fragment that shows details of large catches for each
 * type of species.
 *
 * Created by Cohen Adair on 2016-01-27.
 */
public class BigCatchFragment extends Fragment {

    private static final String ARG_STATS_ID = "arg_stats_id";

    private StatsManager.StatsSpec mStatsSpec;

    public static BigCatchFragment newInstance(int statsId) {
        BigCatchFragment fragment = new BigCatchFragment();

        Bundle args = new Bundle();
        args.putInt(ARG_STATS_ID, statsId);

        fragment.setArguments(args);
        return fragment;
    }

    public BigCatchFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_big_catch, container, false);

        mStatsSpec = StatsManager.getStatsSpec(getContext(), getArguments().getInt(ARG_STATS_ID));

        return view;
    }

}
