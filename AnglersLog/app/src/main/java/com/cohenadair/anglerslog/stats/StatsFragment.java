package com.cohenadair.anglerslog.stats;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.fragments.MasterFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.views.DefaultCardView;

/**
 * The StatsFragment is the fragment that displays statistical summaries of the Logbook's data.
 * Created by Cohen Adair on 2016-01-26.
 */
public class StatsFragment extends MasterFragment {

    private DefaultCardView mSpeciesCard;
    private DefaultCardView mBaitsCard;
    private DefaultCardView mLocationsCard;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.stats_layout, container, false);

        mSpeciesCard = (DefaultCardView)view.findViewById(R.id.species_card);
        mSpeciesCard.init(getContext().getResources().getString(R.string.species_caught), Logbook.getSpeciesCaughtCount(), null);

        mBaitsCard = (DefaultCardView)view.findViewById(R.id.baits_card);
        mBaitsCard.init(getContext().getResources().getString(R.string.baits_used), Logbook.getBaitUsedCount(), null);

        mLocationsCard = (DefaultCardView)view.findViewById(R.id.locations_card);
        mLocationsCard.init(getContext().getResources().getString(R.string.location_success), Logbook.getLocationCatchCount(), null);

        update(getRealActivity());

        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity) {

    }
}
