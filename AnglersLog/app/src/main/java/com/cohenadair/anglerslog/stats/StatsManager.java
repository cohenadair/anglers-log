package com.cohenadair.anglerslog.stats;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.UUID;

/**
 * The StatsManager class is the statistics equivalent of
 * {@link com.cohenadair.anglerslog.utilities.LayoutSpecManager}.
 *
 * Created by Cohen Adair on 2016-01-27.
 */
public class StatsManager {

    public static final int SPECIES = 0;
    public static final int BAITS = 1;
    public static final int LOCATIONS = 2;
    public static final int LONGEST = 3;
    public static final int HEAVIEST = 4;

    @Nullable
    public static StatsSpec getStatsSpec(Context context, int statsId) {
        switch (statsId) {
            case SPECIES:
                return getSpeciesStatsSpec(context, statsId);

            case BAITS:
                return getBaitsStatsSpec(context, statsId);

            case LOCATIONS:
                return getLocationsStatsSpec(context, statsId);

            case LONGEST:
                return getLongestStatsSpec(context, statsId);

            case HEAVIEST:
                return getHeaviestStatsSpec(context, statsId);

            default:
                return null;
        }
    }

    @NonNull
    private static StatsSpec getSpeciesStatsSpec(Context context, int id) {
        return new StatsSpec(
                id,
                context.getResources().getString(R.string.species_stats),
                context.getResources().getString(R.string.species),
                Logbook.getSpeciesCaughtCount(),
                CatchesCountFragment.newInstance(SPECIES)
        );
    }

    @NonNull
    private static StatsSpec getBaitsStatsSpec(Context context, int id) {
        return new StatsSpec(
                id,
                context.getResources().getString(R.string.bait_stats),
                context.getResources().getString(R.string.drawer_baits),
                Logbook.getBaitUsedCount(),
                CatchesCountFragment.newInstance(BAITS),
                new StatsSpec.InteractionListener() {
                    @Override
                    public UserDefineObject onGetObject(UUID id) {
                        return Logbook.getBait(id);
                    }

                    @Override
                    public int onGetLayoutSpecId() {
                        return LayoutSpecManager.LAYOUT_BAITS;
                    }
                }
        );
    }

    @NonNull
    private static StatsSpec getLocationsStatsSpec(Context context, int id) {
        return new StatsSpec(
                id,
                context.getResources().getString(R.string.location_stats),
                context.getResources().getString(R.string.drawer_locations),
                Logbook.getLocationCatchCount(),
                CatchesCountFragment.newInstance(LOCATIONS),
                new StatsSpec.InteractionListener() {
                    @Override
                    public UserDefineObject onGetObject(UUID id) {
                        return Logbook.getLocation(id);
                    }

                    @Override
                    public int onGetLayoutSpecId() {
                        return LayoutSpecManager.LAYOUT_LOCATIONS;
                    }
                }
        );
    }

    @NonNull
    private static StatsSpec getLongestStatsSpec(Context context, int id) {
        return new StatsSpec(
                id,
                context.getResources().getString(R.string.longest_catches),
                BigCatchFragment.newInstance(LONGEST)
        );
    }

    @NonNull
    private static StatsSpec getHeaviestStatsSpec(Context context, int id) {
        return new StatsSpec(
                id,
                context.getResources().getString(R.string.heaviest_catches),
                BigCatchFragment.newInstance(HEAVIEST)
        );
    }

    public static class StatsSpec {

        private int mId;
        private String mActivityTitle;
        private String mUserDefineObjectName;
        private ArrayList<Stats.Quantity> mContent;
        private Fragment mDetailFragment;
        private InteractionListener mCallbacks;

        public interface InteractionListener {
            UserDefineObject onGetObject(UUID id);
            int onGetLayoutSpecId();
        }

        public StatsSpec(int id, String activityTitle, String userDefineObjectName, ArrayList<Stats.Quantity> content, Fragment detailFragment) {
            mId = id;
            mActivityTitle = activityTitle;
            mUserDefineObjectName = userDefineObjectName;
            mContent = content;
            mDetailFragment = detailFragment;
        }

        public StatsSpec(int id, String activityTitle, String userDefineObjectName, ArrayList<Stats.Quantity> content, Fragment detailFragment, InteractionListener callbacks) {
            mId = id;
            mActivityTitle = activityTitle;
            mUserDefineObjectName = userDefineObjectName;
            mContent = content;
            mDetailFragment = detailFragment;
            mCallbacks = callbacks;
        }

        public StatsSpec(int id, String activityTitle, Fragment detailFragment) {
            mId = id;
            mActivityTitle = activityTitle;
            mDetailFragment = detailFragment;
        }

        public int getId() {
            return mId;
        }

        public String getActivityTitle() {
            return mActivityTitle;
        }

        public String getUserDefineObjectName() {
            return mUserDefineObjectName;
        }

        public ArrayList<Stats.Quantity> getContent() {
            return mContent;
        }

        public ArrayList<Stats.Quantity> getAlphaSortedContent() {
            ArrayList<Stats.Quantity> result = new ArrayList<>(mContent);
            Collections.sort(result, new Stats.NameComparator());
            return result;
        }

        public Fragment getDetailFragment() {
            return mDetailFragment;
        }

        public InteractionListener getCallbacks() {
            return mCallbacks;
        }

        public UserDefineObject getObject(int index) {
            if (mCallbacks != null)
                return mCallbacks.onGetObject(mContent.get(index).getId());

            return null;
        }

        public int getLayoutSpecId() {
            if (mCallbacks != null)
                return mCallbacks.onGetLayoutSpecId();

            return -1;
        }
    }
}
