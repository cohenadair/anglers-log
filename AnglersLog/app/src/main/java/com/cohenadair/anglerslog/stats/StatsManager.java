package com.cohenadair.anglerslog.stats;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Stats;

import java.util.ArrayList;

/**
 * The StatsManager class is the statistics equivalent of
 * {@link com.cohenadair.anglerslog.utilities.LayoutSpecManager}.
 *
 * Created by Cohen Adair on 2016-01-27.
 */
public class StatsManager {

    public static final int STATS_SPECIES = 0;
    public static final int STATS_BAITS = 1;
    public static final int STATS_LOCATIONS = 2;
    public static final int STATS_LONGEST = 3;
    public static final int STATS_HEAVIEST = 4;

    @Nullable
    public static StatsSpec getStatsSpec(Context context, int statsId) {
        switch (statsId) {
            case STATS_SPECIES:
                return getSpeciesStatsSpec(context);

            case STATS_BAITS:
                return getBaitsStatsSpec(context);

            case STATS_LOCATIONS:
                return getLocationsStatsSpec(context);

            case STATS_LONGEST:
                return getLongestStatsSpec(context);

            case STATS_HEAVIEST:
                return getHeaviestStatsSpec(context);

            default:
                return null;
        }
    }

    @NonNull
    private static StatsSpec getSpeciesStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.species_caught),
                context.getResources().getString(R.string.species_stats),
                Logbook.getSpeciesCaughtCount(),
                CatchesCountFragment.newInstance(STATS_SPECIES)
        );
    }

    @NonNull
    private static StatsSpec getBaitsStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.baits_used),
                context.getResources().getString(R.string.bait_stats),
                Logbook.getBaitUsedCount(),
                CatchesCountFragment.newInstance(STATS_BAITS)
        );
    }

    @NonNull
    private static StatsSpec getLocationsStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.location_success),
                context.getResources().getString(R.string.location_stats),
                Logbook.getLocationCatchCount(),
                CatchesCountFragment.newInstance(STATS_LOCATIONS)
        );
    }

    private static StatsSpec getLongestStatsSpec(Context context) {
        return null;
    }

    private static StatsSpec getHeaviestStatsSpec(Context context) {
        return null;
    }

    public static class StatsSpec {

        private String mCardTitle;
        private String mActivityTitle;
        private ArrayList<Stats.Quantity> mCardContent;
        private Fragment mDetailFragment;

        public StatsSpec (String cardTitle, String activityTitle, ArrayList<Stats.Quantity> cardContent, Fragment detailFragment) {
            mCardContent = cardContent;
            mCardTitle = cardTitle;
            mActivityTitle = activityTitle;
            mDetailFragment = detailFragment;
        }

        public String getCardTitle() {
            return mCardTitle;
        }

        public String getActivityTitle() {
            return mActivityTitle;
        }

        public ArrayList<Stats.Quantity> getCardContent() {
            return mCardContent;
        }

        public Fragment getDetailFragment() {
            return mDetailFragment;
        }
    }
}
