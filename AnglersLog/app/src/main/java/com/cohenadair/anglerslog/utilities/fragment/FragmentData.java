package com.cohenadair.anglerslog.utilities.fragment;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.ManageCatchFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.fragments.TripFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.CatchListManager;

import java.util.HashMap;

/**
 * FragmentData is used for manipulating fragments throughout the application.
 * Created by Cohen Adair on 2015-09-03.
 */
public class FragmentData {

    private static final String TAG = "FragmentData";

    /**
     * Top level fragments that are normally displayed from the navigation drawer.
     */
    public static final int FRAGMENT_CATCHES    = R.id.nav_catches;
    public static final int FRAGMENT_TRIPS      = R.id.nav_trips;
    /*
    public static final int FRAGMENT_GALLERY    = R.id.nav_photos;
    public static final int FRAGMENT_STATS      = R.id.nav_stats;
    public static final int FRAGMENT_LOCATIONS  = R.id.nav_locations;
    public static final int FRAGMENT_BAITS      = R.id.nav_baits;
    */

    /**
     * Primitive fragments for simple lists displaying objects with only a name attribute.
     * These fragments are used when adding more complex user defines. They do not show in the
     * navigation drawer.
     */
    public static final int PRIMITIVE_SPECIES = 0;

    /**
     * Used to store all fragment and primitive fragment information for reuse.
     */
    private static HashMap<Integer, FragmentInfo> mFragmentInfoMap = null;
    private static HashMap<Integer, PrimitiveFragmentInfo> mSpeciesPrimitiveInfo = null;

    //region Master Fragment Initializing
    /**
     * Used to keep track of the current master-detail fragment pair.
     */
    private static int mCurrentFragmentId = FRAGMENT_CATCHES; // default starting fragment

    public static FragmentInfo fragmentInfo(Context context, int fragmentId) {
        if (mFragmentInfoMap == null)
            initFragmentInfoMap(context);

        return mFragmentInfoMap.get(fragmentId);
    }

    public static FragmentInfo fragmentInfo(int fragmentId) {
        return fragmentInfo(null, fragmentId);
    }

    /**
     * Gets the current selection (or scrolling) position for returning to a list from a detail
     * fragment.
     * @param fragmentId The fragment that's being displayed.
     * @return The position of the most recent selected item.
     */
    public static int selectionPos(int fragmentId) {
        if (mFragmentInfoMap == null)
            return 0;

        return mFragmentInfoMap.get(fragmentId).getPrevSelectionPosition();
    }

    /**
     * Sets the current selection or scroll position for the current fragment.
     * @param fragmentId The id of the fragment position to set.
     * @param selectedPos The position of the most recent selected item in the list.
     */
    public static void selectionPos(int fragmentId, int selectedPos) {
        if (mFragmentInfoMap != null)
            mFragmentInfoMap.get(fragmentId).setPrevSelectionPosition(selectedPos);
    }

    public static int getCurrentFragmentId() {
        return mCurrentFragmentId;
    }

    public static void setCurrentFragmentId(int currentFragmentId) {
        mCurrentFragmentId = currentFragmentId;
    }

    private static void initFragmentInfoMap(Context context) {
        if (context == null) {
            Log.e(TAG, "Context must not be NULL in initFragmentInfoMap().");
            return;
        }

        mFragmentInfoMap = new HashMap<>();
        mFragmentInfoMap.put(FRAGMENT_CATCHES, getCatchesFragmentInfo(context));
        mFragmentInfoMap.put(FRAGMENT_TRIPS, getTripsFragmentInfo(context));
    }

    private static FragmentInfo getCatchesFragmentInfo(Context context) {
        MainActivity activity = (MainActivity)context;
        int id = FRAGMENT_CATCHES;

        FragmentInfo info = new FragmentInfo("fragment_catches");
        FragmentInfo detailInfo = new FragmentInfo("fragment_catch");
        ManageFragmentInfo manageInfo = new ManageFragmentInfo(ManageFragment.newInstance(id), new ManageCatchFragment());

        detailInfo.setFragment(new CatchFragment());

        info.setDetailInfo(detailInfo);
        info.setManageInfo(manageInfo);
        info.setArrayAdapter(new CatchListManager.Adapter(context, Logbook.getInstance().getCatches(), activity.getOnMyListViewItemClick()));
        info.setFragment(MyListFragment.newInstance(id));
        info.setName("Catch");
        info.setId(id);

        return info;
    }

    private static FragmentInfo getTripsFragmentInfo(Context context) {
        MainActivity activity = (MainActivity)context;

        FragmentInfo info = new FragmentInfo("fragment_trips");
        FragmentInfo detailInfo = new FragmentInfo("fragment_trip");

        detailInfo.setFragment(new TripFragment());

        info.setDetailInfo(detailInfo);
        info.setArrayAdapter(new CatchListManager.Adapter(context, Logbook.getInstance().getTrips(), activity.getOnMyListViewItemClick()));
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
        if (mSpeciesPrimitiveInfo == null)
            initPrimitiveFragmentInfoMap();

        return mSpeciesPrimitiveInfo.get(primitiveId);
    }

    private static void initPrimitiveFragmentInfoMap() {
        mSpeciesPrimitiveInfo = new HashMap<>();
        mSpeciesPrimitiveInfo.put(PRIMITIVE_SPECIES, getSpeciesPrimitiveInfo());
    }

    private static PrimitiveFragmentInfo getSpeciesPrimitiveInfo() {
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
