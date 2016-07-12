package com.cohenadair.anglerslog.stats;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DefaultActivity;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The BigCatchFragment is a statistical fragment that shows details of large catches for each
 * type of species.
 *
 * @author Cohen Adair
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
        View view = inflater.inflate(R.layout.fragment_simple_list, container, false);

        int statsId = getArguments().getInt(ARG_STATS_ID);

        StatsManager.StatsSpec spec = StatsManager.getStatsSpec(getContext(), statsId);
        if (spec == null)
            return view;

        mIsLongest = (statsId == StatsManager.LONGEST);
        ((DefaultActivity)getActivity()).setActionBarTitle(spec.getActivityTitle());

        initRecyclerView(view);

        return view;
    }

    private void initRecyclerView(View view) {
        RecyclerView list = (RecyclerView)view.findViewById(R.id.recycler_view);
        list.setAdapter(new CatchListManager.Adapter(getContext(), getCatches(), getOnClickItemListener(), getOnGetContentListener()));
        list.setHasFixedSize(true);
        list.setLayoutManager(new LinearLayoutManager(getContext()));
    }

    /**
     * Gets the biggest {@link Catch} for each {@link Species} in the {@link Logbook}.
     * @return A list of the biggest {@link Catch} objects.
     */
    private ArrayList<UserDefineObject> getCatches() {
        ArrayList<UserDefineObject> catches = new ArrayList<>();
        ArrayList<UserDefineObject> species = Logbook.getSpecies();

        for (UserDefineObject obj : species) {
            Catch biggest = getCatch((Species)obj);

            // skip the Catch if there is no recorded length or weight
            if (biggest == null || hasNoRecord(biggest))
                continue;

            catches.add(biggest);
        }

        return catches;
    }

    @NonNull
    private OnClickInterface getOnClickItemListener() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startActivity(DetailFragmentActivity.getIntent(getContext(), LayoutSpecManager.LAYOUT_CATCHES, id));
            }
        };
    }

    @NonNull
    private CatchListManager.Adapter.GetContentListener getOnGetContentListener() {
        return new CatchListManager.Adapter.GetContentListener() {
            @Override
            public String onGetSubSubtitle(Catch aCatch) {
                return getMeasurementString(aCatch);
            }
        };
    }

    private String getMeasurementString(Catch aCatch) {
        return (mIsLongest ? aCatch.getLengthAsStringWithUnits() : aCatch.getWeightAsStringWithUnits());
    }

    private Catch getCatch(Species species) {
        return mIsLongest ? Logbook.getLongestCatch(species) : Logbook.getHeaviestCatch(species);
    }

    private boolean hasNoRecord(Catch aCatch) {
        return mIsLongest ? aCatch.getLength() == -1 : aCatch.getWeight() == -1;
    }
}
