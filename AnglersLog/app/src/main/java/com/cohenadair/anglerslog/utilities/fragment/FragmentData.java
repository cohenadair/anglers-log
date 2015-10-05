package com.cohenadair.anglerslog.utilities.fragment;

import android.app.Activity;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.ArrayAdapter;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.ManageCatchFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.fragments.TripFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.HashMap;

/**
 * FragmentData is used for manipulating fragments throughout the application.
 * Created by Cohen Adair on 2015-09-03.
 */
public class FragmentData {

    /**
     * Top level fragments that are normally displayed from the navigation drawer.
     */
    public static final int FRAGMENT_CATCHES    = R.id.nav_catches;
    public static final int FRAGMENT_TRIPS      = R.id.nav_trips;
    public static final int FRAGMENT_GALLERY    = R.id.nav_photos;
    public static final int FRAGMENT_STATS      = R.id.nav_stats;
    public static final int FRAGMENT_LOCATIONS  = R.id.nav_locations;
    public static final int FRAGMENT_BAITS      = R.id.nav_baits;

    /**
     * Primitive fragments for simple lists displaying objects with only a name attribute.
     * These fragments are used when adding more complex user defines. They do not show in the
     * navigation drawer.
     */
    public static final int PRIMITIVE_SPECIES = 0;

    //region Navigation Drawer Fragments
    /**
     * Used to store previous selections for MyListFragment instances.
     */
    private static HashMap<Integer, Integer> mSelectionPositions = new HashMap<>();

    /**
     * Used to keep track of the current master-detail fragment pair.
     */
    private static int mCurrentFragmentId = FRAGMENT_CATCHES; // default starting fragment

    @Nullable
    public static FragmentInfo fragmentInfo(Activity activity, int fragmentId) {
        switch (fragmentId) {
            case FRAGMENT_CATCHES:
                return catchesFragmentInfo(activity);

            case FRAGMENT_TRIPS:
                return tripsFragmentInfo(activity);

            default:
                Log.e("FragmentData", "Invalid fragment id in fragmentInfo()");
                break;
        }

        return null;
    }

    /**
     * Gets the current selection (or scrolling) position for returning to a list from a detail
     * fragment.
     * @param fragmentId The fragment that's being displayed.
     * @return The position of the most recent selected item.
     */
    public static int selectionPos(int fragmentId) {
        if (mSelectionPositions.containsKey(fragmentId))
            return mSelectionPositions.get(fragmentId);

        return 0;
    }

    /**
     * Sets the current selection or scroll position for the current fragment.
     * @param fragmentId The id of the fragment position to set.
     * @param selectedPos The position of the most recent selected item in the list.
     */
    public static void selectionPos(int fragmentId, int selectedPos) {
        mSelectionPositions.put(fragmentId, selectedPos);
    }

    public static int getCurrentFragmentId() {
        return mCurrentFragmentId;
    }

    public static void setCurrentFragmentId(int currentFragmentId) {
        mCurrentFragmentId = currentFragmentId;
    }

    private static FragmentInfo catchesFragmentInfo(final Activity activity) {
        int id = FRAGMENT_CATCHES;

        FragmentInfo info = new FragmentInfo("fragment_catches");
        FragmentInfo detailInfo = new FragmentInfo("fragment_catch");
        ManageFragmentInfo manageInfo = new ManageFragmentInfo(ManageFragment.newInstance(id), new ManageCatchFragment());

        detailInfo.setFragment(new CatchFragment());

        info.setDetailInfo(detailInfo);
        info.setManageInfo(manageInfo);
        info.setArrayAdapter(new ArrayAdapter<>(activity, android.R.layout.simple_list_item_1, Logbook.getInstance().getCatches()));
        info.setFragment(MyListFragment.newInstance(id));
        info.setName("Catch");
        info.setId(id);

        return info;
    }

    private static FragmentInfo tripsFragmentInfo(Activity activity) {
        FragmentInfo info = new FragmentInfo("fragment_trips");
        FragmentInfo detailInfo = new FragmentInfo("fragment_trip");

        detailInfo.setFragment(new TripFragment());

        info.setDetailInfo(detailInfo);
        info.setArrayAdapter(new ArrayAdapter<>(activity, android.R.layout.simple_list_item_1, Logbook.getInstance().getTrips()));
        info.setId(FRAGMENT_TRIPS);
        info.setFragment(MyListFragment.newInstance(info.getId()));

        return info;
    }
    //endregion

    //region Primitive Fragments
    /**
     * Loads information for displaying "primitive" user defines in a DialogFragment.
     * @param primitiveId The id of the primitive user define to retrieve.
     * @return A PrimitiveFragmentInfo instance for the associated user define.
     */
    @Nullable
    public static PrimitiveFragmentInfo primitiveInfo(int primitiveId) {
        switch (primitiveId) {
            case PRIMITIVE_SPECIES:
                return speciesPrimitiveInfo();

            default:
                Log.e("FragmentData", "Invalid primitive id in primitiveInfo()");
                break;
        }

        return null;
    }

    private static PrimitiveFragmentInfo speciesPrimitiveInfo() {
        final PrimitiveFragmentInfo info = new PrimitiveFragmentInfo();

        info.setName("species");
        info.setCapitalizedName("Species");
        info.setItems(Logbook.getInstance().getSpecies());
        info.setManageInterface(new PrimitiveFragmentInfo.ManageInterface() {
            @Override
            public boolean onAddItem(String name) {
                return Logbook.getInstance().addSpecies(new Species(name));
            }

            @Override
            public UserDefineObject onClickItem(int position) {
                return Logbook.getInstance().speciesAtPos(position);
            }

            @Override
            public void onConfirmDelete() {
                Logbook.getInstance().cleanSpecies();
            }

            @Override
            public void onEditItem(int position, String newName) {
                Logbook.getInstance().editSpecies(position, newName);
            }
        });

        return info;
    }
    //endregion

}
