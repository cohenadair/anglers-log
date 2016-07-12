package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.annotation.Nullable;
import android.widget.ArrayAdapter;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.baits.BaitFragment;
import com.cohenadair.anglerslog.baits.BaitListManager;
import com.cohenadair.anglerslog.baits.ManageBaitFragment;
import com.cohenadair.anglerslog.catches.CatchFragment;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.catches.ManageCatchFragment;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.gallery.GalleryFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.locations.LocationFragment;
import com.cohenadair.anglerslog.locations.LocationListManager;
import com.cohenadair.anglerslog.locations.ManageLocationFragment;
import com.cohenadair.anglerslog.map.LocationMapFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.utilities.SortingMethod;
import com.cohenadair.anglerslog.model.utilities.SortingUtils;
import com.cohenadair.anglerslog.settings.SettingsFragment;
import com.cohenadair.anglerslog.stats.StatsFragment;
import com.cohenadair.anglerslog.trips.ManageTripFragment;
import com.cohenadair.anglerslog.trips.TripFragment;
import com.cohenadair.anglerslog.trips.TripListManager;

import java.util.ArrayList;
import java.util.UUID;

/**
 * LayoutSpecManager is used to modify and control the current layout spec.  Most of the
 * application's layouts are similar; they just show different content.  This class, in
 * conjunction with {@link LayoutSpec} are used to make that process much easier.
 *
 * @author Cohen Adair
 */
public class LayoutSpecManager {
    // force singleton
    private LayoutSpecManager() { }

    /**
     * This interface must be implemented by any activity utilizing the LayoutSpecManager class.
     */
    public interface InteractionListener {
        OnClickInterface getOnMyListFragmentItemClick();
    }

    /**
     * Top level fragments that are normally displayed from the navigation drawer.
     */
    public static final int LAYOUT_CATCHES = R.id.nav_catches;
    public static final int LAYOUT_LOCATIONS = R.id.nav_locations;
    public static final int LAYOUT_MAP = R.id.nav_map;
    public static final int LAYOUT_BAITS = R.id.nav_baits;
    public static final int LAYOUT_TRIPS = R.id.nav_trips;
    public static final int LAYOUT_STATS = R.id.nav_stats;
    public static final int LAYOUT_GALLERY = R.id.nav_gallery;
    public static final int LAYOUT_SETTINGS = R.id.nav_settings;
    public static final int LAYOUT_HELP = R.id.nav_help;
    public static final int LAYOUT_RATE = R.id.nav_rate;
    public static final int LAYOUT_TWITTER = R.id.nav_twitter;
    public static final int LAYOUT_INSTAGRAM = R.id.nav_instagram;

    //region Layout Spec Definitions
    @Nullable
    public static LayoutSpec layoutSpec(Context context, int id) {
        LayoutSpecActivity layoutSpecContext = (LayoutSpecActivity)context;

        switch (id) {
            case LAYOUT_CATCHES:
                return getCatchesLayoutSpec(layoutSpecContext);

            case LAYOUT_LOCATIONS:
                return getLocationsLayoutSpec(layoutSpecContext);

            case LAYOUT_MAP:
                return getMapLayoutSpec(layoutSpecContext);

            case LAYOUT_BAITS:
                return getBaitsLayoutSpec(layoutSpecContext);

            case LAYOUT_TRIPS:
                return getTripsLayoutSpec(layoutSpecContext);

            case LAYOUT_STATS:
                return getStatsLayoutSpec(layoutSpecContext);

            case LAYOUT_GALLERY:
                return getGalleryLayoutSpec(layoutSpecContext);

            case LAYOUT_SETTINGS:
                return getSettingsLayoutSpec(layoutSpecContext);

            case LAYOUT_RATE:
                return getRateLayoutSpec(layoutSpecContext);

            case LAYOUT_HELP:
                return getHelpLayoutSpec(layoutSpecContext);

            case LAYOUT_TWITTER:
                return getTwitterLayoutSpec(layoutSpecContext);

            case LAYOUT_INSTAGRAM:
                return getInstagramLayoutSpec(layoutSpecContext);

            default:
                return getCatchesLayoutSpec(layoutSpecContext);
        }
    }

    /**
     * Used to quickly show the details of a complex {@link UserDefineObject} such as a
     * {@link com.cohenadair.anglerslog.model.user_defines.Location}.
     */
    @Nullable
    public static DetailFragment getDetailFragment(int layoutId) {
        switch (layoutId) {
            case LAYOUT_CATCHES:
                return new CatchFragment();

            case LAYOUT_LOCATIONS:
                return new LocationFragment();

            case LAYOUT_BAITS:
                return new BaitFragment();

            case LAYOUT_TRIPS:
                return new TripFragment();
        }

        return null;
    }

    /**
     * Used to easily get an object for different layouts. This is needed because different
     * {@link Logbook} methods need to be called depending on the layout.
     */
    @Nullable
    public static UserDefineObject getObject(int layoutId, UUID id) {
        switch (layoutId) {
            case LAYOUT_CATCHES:
                return Logbook.getCatch(id);

            case LAYOUT_LOCATIONS:
                return Logbook.getLocation(id);

            case LAYOUT_BAITS:
                return Logbook.getBait(id);

            case LAYOUT_TRIPS:
                return Logbook.getTrip(id);
        }

        return null;
    }

    /**
     * Checks to see if the given layout id is meant to be a link to a web page.
     * @param layoutId The layout id.
     * @return True if link; false otherwise.
     */
    public static boolean isLink(int layoutId) {
        return (layoutId == LAYOUT_HELP ||
                layoutId == LAYOUT_TWITTER ||
                layoutId == LAYOUT_INSTAGRAM ||
                layoutId == LAYOUT_RATE
        );
    }

    private static LayoutSpec getCatchesLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_catches),
                context.getResources().getString(R.string.catch_string)
        );

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter(String searchQuery, SortingMethod sortingMethod, boolean allowMultipleSelection) {
                return new CatchListManager.Adapter(
                        context,
                        Logbook.getCatches(searchQuery, sortingMethod),
                        context.isTwoPane(),
                        allowMultipleSelection,
                        onMasterItemClick
                );
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeCatch(id);
                spec.removeUserDefine(context, Logbook.getCatch(id), removed, R.string.success_catch_delete);
                return removed;
            }
        });

        SortingMethod[] methods = {
                SortingUtils.bySpecies(),
                SortingUtils.byLocation(),
                SortingUtils.byFavorite(),
                SortingUtils.byNewestToOldest(),
                SortingUtils.byOldestToNewest()
        };
        spec.setSortingMethods(methods);

        spec.setId(LAYOUT_CATCHES);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new CatchFragment());
        spec.setManageFragment(new ManageCatchFragment());

        return spec;
    }

    private static LayoutSpec getLocationsLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_locations),
                context.getResources().getString(R.string.location)
        );

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter(String searchQuery, SortingMethod sortingMethod, boolean allowMultipleSelection) {
                return new LocationListManager.Adapter(
                        context,
                        Logbook.getLocations(searchQuery, sortingMethod),
                        context.isTwoPane(),
                        allowMultipleSelection,
                        onMasterItemClick
                );
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeLocation(id);
                spec.removeUserDefine(context, Logbook.getLocation(id), removed, R.string.success_location_delete);
                return removed;
            }
        });

        spec.setSelectionListener(new LayoutSpec.OnSelectionListener() {
            @Override
            public void onSelect(UUID selectionId, final LayoutSpec.OnSelectionFinishedCallback callback) {
                final ArrayList<UserDefineObject> fishingSpots = Logbook.getLocation(selectionId).getFishingSpots();
                final ArrayAdapter<String> adapter = new ArrayAdapter<>(context, android.R.layout.simple_list_item_1);
                for (UserDefineObject fishingSpot : fishingSpots)
                    adapter.add(fishingSpot.getName());

                AlertUtils.showSelection(context, context.getSupportFragmentManager(), adapter, new AlertUtils.OnSelectionDialogCallback() {
                    @Override
                    public void onSelect(int position) {
                        if (callback != null)
                            callback.onFinish(fishingSpots.get(position).getId());
                    }
                });
            }
        });

        SortingMethod[] methods = {
                SortingUtils.byName(),
                SortingUtils.byNumberOfFishingSpots(),
                SortingUtils.byNumberOfCatches()
        };
        spec.setSortingMethods(methods);

        spec.setId(LAYOUT_LOCATIONS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new LocationFragment());
        spec.setManageFragment(new ManageLocationFragment());

        return spec;
    }

    private static LayoutSpec getMapLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_map),
                context.getResources().getString(R.string.drawer_map)
        );

        spec.setId(LAYOUT_MAP);
        spec.setMasterFragment(new LocationMapFragment());

        return spec;
    }

    private static LayoutSpec getBaitsLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_baits),
                context.getResources().getString(R.string.bait)
        );

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter(String searchQuery, SortingMethod sortingMethod, boolean allowMultipleSelection) {
                return new BaitListManager.Adapter(
                        context,
                        Logbook.getBaitsAndCategories(searchQuery, sortingMethod),
                        context.isTwoPane(),
                        allowMultipleSelection,
                        onMasterItemClick
                );
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeBait(id);
                spec.removeUserDefine(context, Logbook.getBait(id), removed, R.string.success_bait_delete);
                return removed;
            }
        });

        spec.setOnGetTitleCallback(new LayoutSpec.OnGetTitleCallback() {
            @Override
            public String onGetTitle() {
                return spec.getTitleName(Logbook.getBaitCount());
            }
        });

        SortingMethod[] methods = {
                SortingUtils.byName(),
                SortingUtils.byNumberOfCatches()
        };
        spec.setSortingMethods(methods);

        spec.setId(LAYOUT_BAITS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new BaitFragment());
        spec.setManageFragment(new ManageBaitFragment());

        return spec;
    }

    private static LayoutSpec getTripsLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_trips),
                context.getResources().getString(R.string.trip)
        );

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter(String searchQuery, SortingMethod sortingMethod, boolean allowMultipleSelection) {
                return new TripListManager.Adapter(
                        context,
                        Logbook.getTrips(searchQuery, sortingMethod),
                        context.isTwoPane(),
                        allowMultipleSelection,
                        onMasterItemClick
                );
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeTrip(id);
                spec.removeUserDefine(context, Logbook.getTrip(id), removed, R.string.success_trip_delete);
                return removed;
            }
        });

        SortingMethod[] methods = {
                SortingUtils.byName(),
                SortingUtils.byNewestToOldest(),
                SortingUtils.byOldestToNewest(),
                SortingUtils.byNumberOfCatches()
        };
        spec.setSortingMethods(methods);

        spec.setId(LAYOUT_TRIPS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new TripFragment());
        spec.setManageFragment(new ManageTripFragment());

        return spec;
    }

    private static LayoutSpec getStatsLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_stats),
                context.getResources().getString(R.string.drawer_stats)
        );

        spec.setId(LAYOUT_STATS);
        spec.setMasterFragment(new StatsFragment());

        return spec;
    }

    private static LayoutSpec getGalleryLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_gallery),
                context.getResources().getString(R.string.drawer_gallery)
        );

        spec.setId(LAYOUT_GALLERY);
        spec.setMasterFragment(new GalleryFragment());

        return spec;
    }

    private static LayoutSpec getSettingsLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec(
                context.getResources().getString(R.string.drawer_settings),
                context.getResources().getString(R.string.drawer_settings)
        );

        spec.setId(LAYOUT_SETTINGS);
        spec.setMasterFragment(new SettingsFragment());

        return spec;
    }

    private static LayoutSpec getRateLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec();

        spec.setId(LAYOUT_RATE);
        spec.setOnClickMenuItemIntent(IntentUtils.getStore(context));

        return spec;
    }

    private static LayoutSpec getHelpLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec();

        spec.setId(LAYOUT_HELP);
        spec.setOnClickMenuItemIntent(IntentUtils.getActionView(context.getResources().getString(R.string.website)));

        return spec;
    }

    private static LayoutSpec getTwitterLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec();

        spec.setId(LAYOUT_TWITTER);
        spec.setOnClickMenuItemIntent(IntentUtils.getTwitter(context, R.string.hashtag));

        return spec;
    }

    private static LayoutSpec getInstagramLayoutSpec(final LayoutSpecActivity context) {
        final LayoutSpec spec = new LayoutSpec();

        spec.setId(LAYOUT_INSTAGRAM);
        spec.setOnClickMenuItemIntent(IntentUtils.getInstagram(context, R.string.hashtag));

        return spec;
    }
    //endregion

}
