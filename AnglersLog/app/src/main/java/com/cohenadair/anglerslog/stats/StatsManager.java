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
 * @author Cohen Adair
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
                R.drawable.ic_catches,
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
                R.drawable.ic_bait,
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
                R.drawable.ic_location,
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
                -1,
                context.getResources().getString(R.string.longest_catches),
                BigCatchFragment.newInstance(LONGEST)
        );
    }

    @NonNull
    private static StatsSpec getHeaviestStatsSpec(Context context, int id) {
        return new StatsSpec(
                id,
                -1,
                context.getResources().getString(R.string.heaviest_catches),
                BigCatchFragment.newInstance(HEAVIEST)
        );
    }

    /**
     * Stores any kind of data needed for different kinds of statistical information.
     */
    public static class StatsSpec {

        private int mId;
        private String mActivityTitle;
        private String mUserDefineObjectName;
        private ArrayList<Stats.Quantity> mContent;
        private Fragment mDetailFragment;
        private InteractionListener mCallbacks;
        private int mIconResource;

        public interface InteractionListener {
            UserDefineObject onGetObject(UUID id);
            int onGetLayoutSpecId();
        }

        public StatsSpec(int id, int iconResource, String activityTitle, String userDefineObjectName, ArrayList<Stats.Quantity> content, Fragment detailFragment) {
            mId = id;
            mIconResource = iconResource;
            mActivityTitle = activityTitle;
            mUserDefineObjectName = userDefineObjectName;
            mContent = content;
            mDetailFragment = detailFragment;

            // make sure content is sorted for selections
            if (mContent != null)
                Collections.sort(mContent, new Stats.NameComparator());
        }

        public StatsSpec(int id, int iconResource, String activityTitle, String userDefineObjectName, ArrayList<Stats.Quantity> content, Fragment detailFragment, InteractionListener callbacks) {
            this(id, iconResource, activityTitle, userDefineObjectName, content, detailFragment);
            mCallbacks = callbacks;
        }

        public StatsSpec(int id, int iconResource, String activityTitle, Fragment detailFragment) {
            this(id, iconResource, activityTitle, null, null, detailFragment);
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

        public Fragment getDetailFragment() {
            return mDetailFragment;
        }

        public InteractionListener getCallbacks() {
            return mCallbacks;
        }

        public int getIconResource() {
            return mIconResource;
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
