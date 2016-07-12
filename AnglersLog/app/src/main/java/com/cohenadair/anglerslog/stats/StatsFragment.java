package com.cohenadair.anglerslog.stats;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.CardDetailActivity;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.fragments.MasterFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.DefaultCardView;

import java.util.UUID;

/**
 * The StatsFragment is the fragment that displays statistical summaries of the Logbook's data.
 * @author Cohen Adair
 */
public class StatsFragment extends MasterFragment {

    private DefaultCardView mSpeciesCard;
    private DefaultCardView mBaitsCard;
    private DefaultCardView mLocationsCard;
    private DefaultCardView mLongestCatchCard;
    private DefaultCardView mHeaviestCatchCard;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setClearMenuOnCreate(true);
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.stats_layout, container, false);

        mSpeciesCard = (DefaultCardView)view.findViewById(R.id.species_card);
        mBaitsCard = (DefaultCardView)view.findViewById(R.id.baits_card);
        mLocationsCard = (DefaultCardView)view.findViewById(R.id.locations_card);
        mLongestCatchCard = (DefaultCardView)view.findViewById(R.id.longest_catch_card);
        mHeaviestCatchCard = (DefaultCardView)view.findViewById(R.id.heaviest_catch_card);

        updateInterface();

        return view;
    }

    @Override
    public void updateInterface() {
        boolean hasCatches = Logbook.getCatchCount() > 0;

        ViewUtils.setVisibility(mSpeciesCard, hasCatches);
        ViewUtils.setVisibility(mBaitsCard, hasCatches);
        ViewUtils.setVisibility(mLocationsCard, hasCatches);

        if (hasCatches) {
            mSpeciesCard.initWithList(
                    getContext().getResources().getString(R.string.species_caught),
                    Logbook.getSpeciesCaughtCount(),
                    new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            startCardDetailActivity(StatsManager.SPECIES);
                        }
                    }
            );
            mSpeciesCard.setIconImage(R.drawable.ic_catches);

            mBaitsCard.initWithList(
                    getContext().getResources().getString(R.string.baits_used),
                    Logbook.getBaitUsedCount(),
                    new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            startCardDetailActivity(StatsManager.BAITS);
                        }
                    }
            );
            mBaitsCard.setIconImage(R.drawable.ic_bait);

            mLocationsCard.initWithList(
                    getContext().getResources().getString(R.string.location_success),
                    Logbook.getLocationCatchCount(),
                    new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            startCardDetailActivity(StatsManager.LOCATIONS);
                        }
                    }
            );
            mLocationsCard.setIconImage(R.drawable.ic_location);
        }

        updateBigCatchCard(R.string.longest_catch, mLongestCatchCard, Logbook.getLongestCatch(), StatsManager.LONGEST);
        updateBigCatchCard(R.string.heaviest_catch, mHeaviestCatchCard, Logbook.getHeaviestCatch(), StatsManager.HEAVIEST);
    }

    private void startCardDetailActivity(int statsId) {
        Intent intent = new Intent(getContext(), CardDetailActivity.class);
        intent.putExtra(CardDetailActivity.EXTRA_TWO_PANE, Utils.isTwoPane(getActivity()));
        intent.putExtra(CardDetailActivity.EXTRA_STATS_ID, statsId);
        startActivity(intent);
    }

    private void startUserDefineDetailActivity(int layoutSpecId, UUID userDefineObjectId) {
        startActivity(DetailFragmentActivity.getIntent(getContext(), layoutSpecId, userDefineObjectId));
    }

    private void updateBigCatchCard(int titleId, DefaultCardView card, final Catch aCatch, final int statsId) {
        ViewUtils.setVisibility(card, aCatch != null);

        if (aCatch == null)
            return;

        String measurementStr = ((statsId == StatsManager.LONGEST) ? aCatch.getLengthAsStringWithUnits() : aCatch.getWeightAsStringWithUnits());
        if (!measurementStr.isEmpty())
            measurementStr = " - " + measurementStr;

        card.initWithDisplayLabel(
                getContext().getResources().getString(titleId) + measurementStr,
                aCatch.getSpeciesAsString(),
                aCatch.getDateAsString(),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startUserDefineDetailActivity(LayoutSpecManager.LAYOUT_CATCHES, aCatch.getId());
                    }
                },
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startCardDetailActivity(statsId);
                    }
                }
        );

        String fileName = aCatch.getRandomPhoto();
        if (fileName != null)
            card.setBannerImage(PhotoUtils.privatePhotoPath(aCatch.getRandomPhoto()));
    }
}
