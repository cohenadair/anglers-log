package com.cohenadair.anglerslog.utilities;

import android.app.Activity;
import android.content.res.Resources;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.MyListFragment;
import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * FragmentUtils is used for manipulating fragments throughout the application.
 * Created by Cohen Adair on 2015-09-03.
 */
public class FragmentUtils {

    public static final int FRAGMENT_CATCHES = 0;

    public static FragmentInfo fragmentInfo(Activity anActivity, int aFragmentId) {
        switch (aFragmentId) {
            case FRAGMENT_CATCHES:
                return catchesFragmentInfo(anActivity);
            default:
                Log.e("FragmentUtils", "Invalid fragment id in fragmentInfo()");
                break;
        }

        return null;
    }

    private static FragmentInfo catchesFragmentInfo(Activity anActivity) {
        FragmentInfo info = new FragmentInfo("fragment_catches");
        FragmentInfo detailInfo = new FragmentInfo("fragment_catch");

        detailInfo.setFragment(new CatchFragment());

        info.setDetailInfo(detailInfo);
        info.setArrayAdapter(new ArrayAdapter<Catch>(anActivity, android.R.layout.simple_list_item_1, Logbook.getInstance().getCatches()));
        info.setFragment(MyListFragment.newInstance(FRAGMENT_CATCHES));
        info.setId(FragmentUtils.FRAGMENT_CATCHES);

        return info;
    }

    public static LinearLayout.LayoutParams standardLayoutParams(Resources resources, int weightId) {
        return new LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.MATCH_PARENT,
                Utils.getFloat(resources, weightId)
        );
    }

}
