package com.cohenadair.anglerslog.stats;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DefaultActivity;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailView;

import java.util.ArrayList;

/**
 * The BigCatchFragment is a statistical fragment that shows details of large catches for each
 * type of species.
 *
 * Created by Cohen Adair on 2016-01-27.
 */
public class BigCatchFragment extends Fragment {

    private static final String ARG_STATS_ID = "arg_stats_id";

    private boolean mIsLongest;

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

        int statsId = getArguments().getInt(ARG_STATS_ID);

        StatsManager.StatsSpec spec = StatsManager.getStatsSpec(getContext(), statsId);
        if (spec == null)
            return view;

        mIsLongest = (statsId == StatsManager.STATS_LONGEST);
        ((DefaultActivity)getActivity()).setActionBarTitle(spec.getActivityTitle());

        initContainer(view);

        return view;
    }

    private void initContainer(View view) {
        boolean viewAdded = false;

        LinearLayout container = (LinearLayout)view.findViewById(R.id.container);
        ArrayList<UserDefineObject> species = Logbook.getSpecies();

        for (UserDefineObject obj : species) {
            final Catch biggest = getCatch((Species)obj);

            if (biggest == null || hasNoRecord(biggest))
                continue;

            MoreDetailView v = new MoreDetailView(getContext());

            v.useDefaultSpacing();
            v.useDefaultStyle();

            v.setTitle(biggest.getSpeciesAsString() + getMeasurementString(biggest));
            v.setSubtitle(biggest.getDateTimeAsString());

            v.setOnClickDetailButton(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    startActivity(Utils.getDetailActivityIntent(getContext(), LayoutSpecManager.LAYOUT_CATCHES, biggest.getId()));
                }
            });

            container.addView(v);
            viewAdded = true;
        }

        TextView noInfoView = (TextView)view.findViewById(R.id.no_info_text_view);
        noInfoView.setText(mIsLongest ? R.string.no_recorded_length : R.string.no_recorded_weight);
        Utils.toggleVisibility(noInfoView, !viewAdded);
    }

    private String getMeasurementString(Catch aCatch) {
        return " (" + (mIsLongest ? aCatch.getLengthAsStringWithUnits() : aCatch.getWeightAsStringWithUnits()) + ")";
    }

    private Catch getCatch(Species species) {
        return mIsLongest ? Logbook.getLongestCatch(species) : Logbook.getHeaviestCatch(species);
    }

    private boolean hasNoRecord(Catch aCatch) {
        return mIsLongest ? aCatch.getLength() == -1 : aCatch.getWeight() == -1;
    }
}
