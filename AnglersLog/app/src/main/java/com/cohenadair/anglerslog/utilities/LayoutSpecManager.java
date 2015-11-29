package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.baits.BaitFragment;
import com.cohenadair.anglerslog.baits.BaitListManager;
import com.cohenadair.anglerslog.baits.ManageBaitFragment;
import com.cohenadair.anglerslog.catches.CatchFragment;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.catches.ManageCatchFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;

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
    public static final int LAYOUT_BAITS = R.id.nav_baits;

    //region Layout Spec Definitions
    @Nullable
    public static LayoutSpec layoutSpec(Context context, int id) {
        switch (id) {
            case LAYOUT_CATCHES:
                return getCatchesLayoutSpec(context);
            case LAYOUT_BAITS:
                return getBaitsLayoutSpec(context);
        }

        return null;
    }

    private static LayoutSpec getCatchesLayoutSpec(final Context context) {
        final OnClickInterface onMasterItemClick = ((InteractionListener)context).getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("catches", "catch", "Catch");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new CatchListManager.Adapter(context, Logbook.getCatches(), onMasterItemClick);
            }

            @Override
            public void onUserDefineRemove(UUID id) {
                if (Logbook.removeCatch(id)) {
                    spec.updateViews((LayoutSpecActivity) context);
                    Utils.showToast(context, R.string.success_catch_delete);
                } else
                    Utils.showErrorAlert(context, R.string.error_catch_delete);
            }
        });

        spec.setId(LAYOUT_CATCHES);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new CatchFragment());
        spec.setManageFragment(new ManageCatchFragment());

        return spec;
    }

    private static LayoutSpec getBaitsLayoutSpec(final Context context) {
        final OnClickInterface onMasterItemClick = ((InteractionListener)context).getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("baits", "bait", "Bait");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new BaitListManager.Adapter(context, Logbook.getBaitsAndCategories(), onMasterItemClick);
            }

            @Override
            public void onUserDefineRemove(UUID id) {
                if (Logbook.removeBait(id)) {
                    spec.updateViews((LayoutSpecActivity) context);
                    Utils.showToast(context, R.string.success_bait_delete);
                } else
                    Utils.showErrorAlert(context, R.string.error_bait_delete);
            }
        });

        spec.setId(LAYOUT_BAITS);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new BaitFragment());
        spec.setManageFragment(new ManageBaitFragment());

        return spec;
    }
    //endregion

}
