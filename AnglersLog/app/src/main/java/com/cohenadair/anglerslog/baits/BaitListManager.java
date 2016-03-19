package com.cohenadair.anglerslog.baits;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;

import java.util.ArrayList;

/**
 * The BaitListManager is a utility class for managing the catches list.
 * @author Cohen Adair
 */
public class BaitListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);
        }

        public void setBait(Bait bait) {
            initForComplexLayout();

            setTitle(bait.getName());
            setSubtitle(bait.getCategoryName());
            setSubSubtitle(bait.getCatchCountAsString(getContext()));
            setImage(bait.getRandomPhoto());

            getFavoriteStar().setVisibility(View.GONE);

            updateViews();
        }

        public void setBaitCategory(BaitCategory category) {
            initForHeaderLayout();
            setHeaderText(category.getName());
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean allowMultipleSelection, OnClickInterface callbacks) {
            super(context, items, allowMultipleSelection, callbacks);
        }

        // can't be overridden in the superclass because it needs to return a BaitListManager.ViewHolder
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            return new ViewHolder(inflateComplexItem(parent), this);
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            ViewHolder baitHolder = (ViewHolder)holder;
            UserDefineObject item = getItem(position);

            super.onBind(baitHolder, position);

            if (item instanceof Bait)
                baitHolder.setBait((Bait)item);
            else
                baitHolder.setBaitCategory((BaitCategory)item);
        }

    }
    //endregion

}
