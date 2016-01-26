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
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.locations.LocationFragment;
import com.cohenadair.anglerslog.locations.LocationListManager;
import com.cohenadair.anglerslog.locations.ManageLocationFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
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
 * Created by Cohen Adair on 2015-09-03.
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
    public static final int LAYOUT_BAITS = R.id.nav_baits;
    public static final int LAYOUT_TRIPS = R.id.nav_trips;

    //region Layout Spec Definitions
    @Nullable
    public static LayoutSpec layoutSpec(Context context, int id) {
        LayoutSpecActivity layoutSpecContext = (LayoutSpecActivity)context;

        switch (id) {
            case LAYOUT_CATCHES:
                return getCatchesLayoutSpec(layoutSpecContext);

            case LAYOUT_LOCATIONS:
                return getLocationsLayoutSpec(layoutSpecContext);

            case LAYOUT_BAITS:
                return getBaitsLayoutSpec(layoutSpecContext);

            case LAYOUT_TRIPS:
                return getTripsLayoutSpec(layoutSpecContext);

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

    private static LayoutSpec getCatchesLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("catches", "catch", "Catch");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new CatchListManager.Adapter(context, Logbook.getCatches(), onMasterItemClick);
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeCatch(id);
                spec.removeUserDefine(context, Logbook.getCatch(id), removed, R.string.success_catch_delete);
                return removed;
            }
        });

        spec.setId(LAYOUT_CATCHES);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new CatchFragment());
        spec.setManageFragment(new ManageCatchFragment());
        spec.setClass(Catch.class);

        return spec;
    }

    private static LayoutSpec getLocationsLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("locations", "location", "Location");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new LocationListManager.Adapter(context, Logbook.getLocations(), onMasterItemClick);
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
                final ArrayAdapter<String> adapter = new ArrayAdapter<>(context, android.R.layout.select_dialog_item);
                for (UserDefineObject fishingSpot : fishingSpots)
                    adapter.add(fishingSpot.getName());

                Utils.showSelectionDialog(context, adapter, new Utils.OnSelectionDialogCallback() {
                    @Override
                    public void onSelect(int position) {
                        if (callback != null)
                            callback.onFinish(fishingSpots.get(position).getId());
                    }
                });
            }
        });

        spec.setId(LAYOUT_LOCATIONS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new LocationFragment());
        spec.setManageFragment(new ManageLocationFragment());
        spec.setClass(Location.class);

        return spec;
    }

    private static LayoutSpec getBaitsLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("baits", "bait", "Bait");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new BaitListManager.Adapter(context, Logbook.getBaitsAndCategories(), onMasterItemClick);
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeBait(id);
                spec.removeUserDefine(context, Logbook.getBait(id), removed, R.string.success_bait_delete);
                return removed;
            }
        });

        spec.setId(LAYOUT_BAITS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new BaitFragment());
        spec.setManageFragment(new ManageBaitFragment());
        spec.setClass(Bait.class);

        return spec;
    }

    private static LayoutSpec getTripsLayoutSpec(final LayoutSpecActivity context) {
        final OnClickInterface onMasterItemClick = context.getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("trips", "trip", "Trip");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new TripListManager.Adapter(context, Logbook.getTrips(), onMasterItemClick);
            }

            @Override
            public boolean onUserDefineRemove(UUID id) {
                boolean removed = Logbook.removeTrip(id);
                spec.removeUserDefine(context, Logbook.getTrip(id), removed, R.string.success_trip_delete);
                return removed;
            }
        });

        spec.setId(LAYOUT_TRIPS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new TripFragment());
        spec.setManageFragment(new ManageTripFragment());
        spec.setClass(Trip.class);

        return spec;
    }
    //endregion

}
