package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.ManageCatchFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;

import java.util.UUID;

/**
 * LayoutController is used to modify and control the current layout spec.  Most of the
 * application's layouts are similar; they just show different content.  This class, in
 * conjunction with {@link LayoutSpec} are used to make that process much easier.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public class LayoutController {
    // force singleton
    private LayoutController() { }

    /**
     * This interface must be implemented by any activity utilizing the LayoutController class.
     */
    public interface InteractionListener {
        OnClickInterface getOnMyListFragmentItemClick();
    }

    /**
     * Top level fragments that are normally displayed from the navigation drawer.
     */
    public static final int LAYOUT_CATCHES = R.id.nav_catches;

    /**
     * Used to keep track of the current master-detail fragment pair.
     */
    private static int mCurrentId = LAYOUT_CATCHES; // default starting fragment TODO cache the current selection for app closing/opening
    private static LayoutSpec mCurrent;

    public static void setCurrent(Context context, int id) {
        mCurrentId = id;
        mCurrent = layoutSpec(context, id);
    }

    public static int getCurrentId() {
        return mCurrentId;
    }

    //region LayoutSpec Wrapper Methods
    public static boolean isEditing() {
        return mCurrent.getManageFragment().getContentFragment().isEditing();
    }

    public static void setIsEditing(boolean isEditing) {
        mCurrent.getManageFragment().getContentFragment().setIsEditing(isEditing, null);
    }

    public static void setIsEditing(boolean isEditing, UUID id) {
        mCurrent.getManageFragment().getContentFragment().setIsEditing(isEditing, id);
    }

    public static void setSelectionId(UUID id) {
        mCurrent.setSelectionId(id);
    }

    public static UUID getSelectionId() {
        return mCurrent.getSelectionId();
    }

    public static void removeUserDefine(UUID id) {
        mCurrent.getOnUserDefineRemove().remove(id);
    }

    public static Fragment getMasterFragment() {
        return mCurrent.getMasterFragment();
    }

    public static DetailFragment getDetailFragment() {
        return mCurrent.getDetailFragment();
    }

    public static ManageFragment getManageFragment() {
        return mCurrent.getManageFragment();
    }

    public static ManageContentFragment getManageContentFragment() {
        return mCurrent.getManageFragment().getContentFragment();
    }

    public static ListManager.Adapter getMasterAdapter() {
        return mCurrent.getMasterAdapter();
    }

    public static String getMasterTag() {
        return mCurrent.getMasterFragmentTag();
    }

    public static String getDetailTag() {
        return mCurrent.getDetailFragmentTag();
    }

    public static void updateViews() {
        mCurrent.updateViews();
    }

    @NonNull
    public static String getViewTitle(Context context) {
        return context.getResources().getString(isEditing() ? R.string.action_edit : R.string.new_text) + " " + mCurrent.getName();
    }
    //endregion

    //region Layout Spec Definitions
    @Nullable
    public static LayoutSpec layoutSpec(Context context, int id) {
        switch (id) {
            case LAYOUT_CATCHES:
                return getCatchesFragmentInfo(context);
        }

        return null;
    }

    private static LayoutSpec getCatchesFragmentInfo(final Context context) {
        OnClickInterface onMasterItemClick = ((InteractionListener)context).getOnMyListFragmentItemClick();

        final LayoutSpec spec = new LayoutSpec("catches", "catch", "Catch");

        spec.setMasterFragment(new MyListFragment(), new CatchListManager.Adapter(context, Logbook.getCatches(), onMasterItemClick));
        spec.setDetailFragment(new CatchFragment());
        spec.setManageFragment(new ManageCatchFragment());
        spec.setId(LAYOUT_CATCHES);
        spec.setOnUserDefineRemove(new LayoutSpec.OnUserDefineRemoveListener() {
            @Override
            public void remove(UUID id) {
                Logbook.removeCatch(id);
                spec.getMasterAdapter().notifyDataSetChanged();
                Utils.showToast(context, R.string.success_catch_delete);
            }
        });

        return spec;
    }
    //endregion

}
