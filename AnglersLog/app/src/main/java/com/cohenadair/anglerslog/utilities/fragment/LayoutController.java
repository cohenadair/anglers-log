package com.cohenadair.anglerslog.utilities.fragment;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageCatchFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.fragments.TripFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.CatchListManager;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * LayoutController is used for manipulating fragments throughout the application.
 * Created by Cohen Adair on 2015-09-03.
 */
public class LayoutController {
    private LayoutController() { }

    private static final String TAG = "LayoutController";

    /**
     * Top level fragments that are normally displayed from the navigation drawer.
     */
    public static final int LAYOUT_CATCHES    = R.id.nav_catches;
    public static final int LAYOUT_TRIPS      = R.id.nav_trips;

    /**
     * Primitive fragments for simple lists displaying objects with only a name attribute.
     * These fragments are used when adding more complex user defines. They do not show in the
     * navigation drawer.
     */
    public static final int PRIMITIVE_SPECIES = 0;

    //region Master Fragment Initializing
    /**
     * Used to keep track of the current master-detail fragment pair.
     */
    private static int mCurrentId = LAYOUT_CATCHES; // default starting fragment
    private static LayoutSpec mCurrent;

    public static LayoutSpec getCurrent() {
        return mCurrent;
    }

    public static void setCurrent(Context context, int id) {
        mCurrentId = id;
        mCurrent = layoutSpec(context, id);
    }

    public static int getCurrentId() {
        return mCurrentId;
    }

    //region LayoutSpec Wrapper Methods
    public static boolean isEditing() {
        return mCurrent.manageContentIsEditing();
    }

    public static void setIsEditing(boolean isEditing) {
        mCurrent.setManageContentIsEditing(isEditing);
    }

    public static void setIsEditing(boolean isEditing, int position) {
        mCurrent.setManageContentIsEditing(isEditing, position);
    }

    public static void setSelectionPosition(int position) {
        mCurrent.setPrevSelectionPosition(position);
    }

    public static int getSelectionPosition() {
        return mCurrent.getPrevSelectionPosition();
    }

    public static void removeUserDefine(int position) {
        mCurrent.getOnUserDefineRemove().remove(position);
    }

    public static String getDetailFragmentTag() {
        return mCurrent.detailTag();
    }

    public static DetailFragment getDetailFragment() {
        return (DetailFragment)mCurrent.detailFragment();
    }

    public static ManageFragment getManageFragment() {
        return mCurrent.manageFragment();
    }

    public static ManageContentFragment getManageContentFragment() {
        return mCurrent.manageContentFragment();
    }

    @NonNull
    public static String getViewTitle(Context context) {
        return context.getResources().getString(isEditing() ? R.string.action_edit : R.string.new_text) + " " + mCurrent.getName();
    }

    public static void updateViews() {
        mCurrent.updateViews();
    }
    //endregion

    @Nullable
    public static LayoutSpec layoutSpec(Context context, int id) {
        switch (id) {
            case LAYOUT_CATCHES:
                return getCatchesFragmentInfo(context);
        }

        return null;
    }

    private static LayoutSpec getCatchesFragmentInfo(Context context) {
        final MainActivity activity = (MainActivity)context;
        int id = LAYOUT_CATCHES;

        final LayoutSpec info = new LayoutSpec("fragment_catches");
        LayoutSpec detailInfo = new LayoutSpec("fragment_catch");
        ManageFragmentInfo manageInfo = new ManageFragmentInfo(new ManageFragment(), new ManageCatchFragment());

        detailInfo.setFragment(new CatchFragment());

        info.setDetailInfo(detailInfo);
        info.setManageInfo(manageInfo);
        info.setArrayAdapter(new CatchListManager.Adapter(context, Logbook.getCatches(), activity.getOnMyListViewItemClick()));
        info.setFragment(new MyListFragment());
        info.setName("Catch");
        info.setId(id);

        info.setOnUserDefineRemove(new LayoutSpec.OnUserDefineRemoveListener() {
            @Override
            public void remove(int position) {
                Logbook.removeCatchAtPos(position);
                info.getArrayAdapter().notifyDataSetChanged();
                Utils.showToast(activity, R.string.success_catch_delete);
            }
        });

        return info;
    }

    private static LayoutSpec getTripsFragmentInfo(Context context) {
        MainActivity activity = (MainActivity)context;

        LayoutSpec info = new LayoutSpec("fragment_trips");
        LayoutSpec detailInfo = new LayoutSpec("fragment_trip");

        detailInfo.setFragment(new TripFragment());

        info.setDetailInfo(detailInfo);
        info.setArrayAdapter(new CatchListManager.Adapter(context, Logbook.getTrips(), activity.getOnMyListViewItemClick()));
        info.setId(LAYOUT_TRIPS);
        info.setFragment(new MyListFragment());

        return info;
    }
    //endregion

    //region Primitive Fragments
    /**
     * Loads information for displaying "primitive" user defines in a DialogFragment.
     * @param id The id of the primitive user define to retrieve.
     * @return A PrimitiveFragmentInfo instance for the associated user define.
     */
    @Nullable
    public static PrimitiveFragmentInfo primitiveInfo(int id) {
        switch (id) {
            case PRIMITIVE_SPECIES:
                return getSpeciesPrimitiveInfo();
        }

        return null;
    }

    private static PrimitiveFragmentInfo getSpeciesPrimitiveInfo() {
        final PrimitiveFragmentInfo info = new PrimitiveFragmentInfo();

        info.setName("species");
        info.setCapitalizedName("Species");
        info.setItems(Logbook.getSpecies());
        info.setManageInterface(new PrimitiveFragmentInfo.ManageInterface() {
            @Override
            public boolean onAddItem(String name) {
                return Logbook.addSpecies(new Species(name));
            }

            @Override
            public UserDefineObject onClickItem(int position) {
                return Logbook.speciesAtPos(position);
            }

            @Override
            public void onConfirmDelete() {
                Logbook.cleanSpecies();
            }

            @Override
            public void onEditItem(int position, String newName) {
                Logbook.editSpecies(position, newName);
            }
        });

        return info;
    }
    //endregion

}
