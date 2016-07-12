package com.cohenadair.anglerslog.stats;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
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
        StatsSpec spec = new StatsSpec(id);

        spec.setIconResource(R.drawable.ic_catches);
        spec.setExtendedIconResource(R.drawable.ic_bait);
        spec.setActivityTitle(context.getResources().getString(R.string.species_stats));
        spec.setUserDefineObjectName(context.getResources().getString(R.string.species));
        spec.setContent(Logbook.getSpeciesCaughtCount());
        spec.setDetailFragment(CatchesCountFragment.newInstance(SPECIES));

        spec.setCallbacks(new StatsSpec.InteractionListener() {
            @Override
            public UserDefineObject onGetObject(UUID id) {
                return Logbook.getSpecies(id);
            }

            @Override
            public int onGetLayoutSpecId() {
                return -1;
            }

            @Override
            public ArrayList<Stats.Quantity> onGetExtendedStats(UserDefineObject obj) {
                return Logbook.getBaitUsedCount((Species)obj);
            }
        });

        return spec;
    }

    @NonNull
    private static StatsSpec getBaitsStatsSpec(Context context, int id) {
        StatsSpec spec = new StatsSpec(id);

        spec.setIconResource(R.drawable.ic_bait);
        spec.setExtendedIconResource(R.drawable.ic_catches);
        spec.setActivityTitle(context.getResources().getString(R.string.bait_stats));
        spec.setUserDefineObjectName(context.getResources().getString(R.string.drawer_baits));
        spec.setContent(Logbook.getBaitUsedCount());
        spec.setDetailFragment(CatchesCountFragment.newInstance(BAITS));

        spec.setCallbacks(new StatsSpec.InteractionListener() {
            @Override
            public UserDefineObject onGetObject(UUID id) {
                return Logbook.getBait(id);
            }

            @Override
            public int onGetLayoutSpecId() {
                return LayoutSpecManager.LAYOUT_BAITS;
            }

            @Override
            public ArrayList<Stats.Quantity> onGetExtendedStats(UserDefineObject obj) {
                return Logbook.getSpeciesCaughtCount((Bait)obj);
            }
        });

        return spec;
    }

    @NonNull
    private static StatsSpec getLocationsStatsSpec(Context context, int id) {
        StatsSpec spec = new StatsSpec(id);

        spec.setIconResource(R.drawable.ic_location);
        spec.setExtendedIconResource(R.drawable.ic_catches);
        spec.setActivityTitle(context.getResources().getString(R.string.location_stats));
        spec.setUserDefineObjectName(context.getResources().getString(R.string.drawer_locations));
        spec.setContent(Logbook.getLocationCatchCount());
        spec.setDetailFragment(CatchesCountFragment.newInstance(LOCATIONS));

        spec.setCallbacks(new StatsSpec.InteractionListener() {
            @Override
            public UserDefineObject onGetObject(UUID id) {
                return Logbook.getLocation(id);
            }

            @Override
            public int onGetLayoutSpecId() {
                return LayoutSpecManager.LAYOUT_LOCATIONS;
            }

            @Override
            public ArrayList<Stats.Quantity> onGetExtendedStats(UserDefineObject obj) {
                return Logbook.getSpeciesCaughtCount((Location)obj);
            }
        });

        return spec;
    }

    @NonNull
    private static StatsSpec getLongestStatsSpec(Context context, int id) {
        StatsSpec spec = new StatsSpec(id);

        spec.setActivityTitle(context.getResources().getString(R.string.longest_catches));
        spec.setDetailFragment(BigCatchFragment.newInstance(LONGEST));

        return spec;
    }

    @NonNull
    private static StatsSpec getHeaviestStatsSpec(Context context, int id) {
        StatsSpec spec = new StatsSpec(id);

        spec.setActivityTitle(context.getResources().getString(R.string.heaviest_catches));
        spec.setDetailFragment(BigCatchFragment.newInstance(HEAVIEST));

        return spec;
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
        private int mIconResource = -1;
        private int mExtendedIconResource = -1;

        public interface InteractionListener {
            UserDefineObject onGetObject(UUID id);
            int onGetLayoutSpecId();
            ArrayList<Stats.Quantity> onGetExtendedStats(UserDefineObject obj);
        }

        public StatsSpec(int id) {
            mId = id;
        }

        public int getId() {
            return mId;
        }

        public void setId(int id) {
            mId = id;
        }

        public String getActivityTitle() {
            return mActivityTitle;
        }

        public void setActivityTitle(String activityTitle) {
            mActivityTitle = activityTitle;
        }

        public String getUserDefineObjectName() {
            return mUserDefineObjectName;
        }

        public void setUserDefineObjectName(String userDefineObjectName) {
            mUserDefineObjectName = userDefineObjectName;
        }

        public ArrayList<Stats.Quantity> getContent() {
            return mContent;
        }

        public void setContent(ArrayList<Stats.Quantity> content) {
            if (content != null) {
                mContent = content;
                Collections.sort(mContent, new Stats.NameComparator());
            }
        }

        public Fragment getDetailFragment() {
            return mDetailFragment;
        }

        public void setDetailFragment(Fragment detailFragment) {
            mDetailFragment = detailFragment;
        }

        public InteractionListener getCallbacks() {
            return mCallbacks;
        }

        public void setCallbacks(InteractionListener callbacks) {
            mCallbacks = callbacks;
        }

        public int getIconResource() {
            return mIconResource;
        }

        public void setIconResource(int iconResource) {
            mIconResource = iconResource;
        }

        public int getExtendedIconResource() {
            return mExtendedIconResource;
        }

        public void setExtendedIconResource(int extendedIconResource) {
            mExtendedIconResource = extendedIconResource;
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

        public ArrayList<Stats.Quantity> getExtendedContent(int index) {
            if (mCallbacks == null)
                return null;

            UserDefineObject obj = getObject(index);

            if (obj != null) {
                ArrayList<Stats.Quantity> content = mCallbacks.onGetExtendedStats(obj);
                Collections.sort(content, new Stats.NameComparator());
                return content;
            }

            return null;
        }
    }
}
