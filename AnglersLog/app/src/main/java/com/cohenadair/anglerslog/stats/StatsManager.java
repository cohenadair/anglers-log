package com.cohenadair.anglerslog.stats;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.model.user_defines.Catch;

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
                context.getResources().getString(R.string.species_stats),
                Logbook.getSpeciesCaughtCount(),
                CatchesCountFragment.newInstance(STATS_SPECIES)
        );
    }

    @NonNull
    private static StatsSpec getBaitsStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.bait_stats),
                Logbook.getBaitUsedCount(),
                CatchesCountFragment.newInstance(STATS_BAITS)
        );
    }

    @NonNull
    private static StatsSpec getLocationsStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.location_stats),
                Logbook.getLocationCatchCount(),
                CatchesCountFragment.newInstance(STATS_LOCATIONS)
        );
    }

    @NonNull
    private static StatsSpec getLongestStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.longest_catches),
                Logbook.getLongestCatch(),
                BigCatchFragment.newInstance(STATS_LONGEST)
        );
    }

    @NonNull
    private static StatsSpec getHeaviestStatsSpec(Context context) {
        return new StatsSpec(
                context.getResources().getString(R.string.longest_catches),
                Logbook.getHeaviestCatch(),
                BigCatchFragment.newInstance(STATS_LONGEST)
        );
    }

    public static class StatsSpec {

        private String mActivityTitle;
        private ArrayList<Stats.Quantity> mContent;
        private Catch mBigCatchContent;
        private Fragment mDetailFragment;

        public StatsSpec(String activityTitle, ArrayList<Stats.Quantity> content, Fragment detailFragment) {
            mActivityTitle = activityTitle;
            mContent = content;
            mDetailFragment = detailFragment;
        }

        public StatsSpec(String activityTitle, Catch content, Fragment detailFragment) {
            mActivityTitle = activityTitle;
            mBigCatchContent = content;
            mDetailFragment = detailFragment;
        }

        public String getActivityTitle() {
            return mActivityTitle;
        }

        public ArrayList<Stats.Quantity> getContent() {
            return mContent;
        }

        public Catch getBigCatchContent() {
            return mBigCatchContent;
        }

        public Fragment getDetailFragment() {
            return mDetailFragment;
        }
    }
}
