package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.ManageCatchFragment;
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
        final OnClickInterface onMasterItemClick = ((InteractionListener)context).getOnMyListFragmentItemClick();
        final LayoutSpec spec = new LayoutSpec("catches", "catch", "Catch");

        spec.setListener(new LayoutSpec.InteractionListener() {
            @Override
            public ListManager.Adapter onGetMasterAdapter() {
                return new CatchListManager.Adapter(context, Logbook.getCatches(), onMasterItemClick);
            }

            @Override
            public void onUserDefineRemove(UUID id) {
                Logbook.removeCatch(id);
                spec.updateViews();
                Utils.showToast(context, R.string.success_catch_delete);
            }
        });

        spec.setId(LAYOUT_CATCHES);
        spec.setMasterFragment(new MyListFragment());
        spec.setDetailFragment(new CatchFragment());
        spec.setManageFragment(new ManageCatchFragment());

        return spec;
    }
    //endregion

}
