package com.cohenadair.anglerslog.stats;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;

/**
 * A statistics fragment used to show the number of catches for a particular
 * {@link com.cohenadair.anglerslog.model.user_defines.UserDefineObject}.
 *
 * Created by Cohen Adair on 2016-01-27.
 */
public class CatchesCountFragment extends Fragment {

    private static final String ARG_STATS_ID = "arg_stats_id";

    private StatsManager.StatsSpec mStatsSpec;

    public static CatchesCountFragment newInstance(int statsId) {
        CatchesCountFragment fragment = new CatchesCountFragment();

        Bundle args = new Bundle();
        args.putInt(ARG_STATS_ID, statsId);

        fragment.setArguments(args);
        return fragment;
    }

    public CatchesCountFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catches_count, container, false);

        mStatsSpec = StatsManager.getStatsSpec(getContext(), getArguments().getInt(ARG_STATS_ID));

        return view;
    }
}
