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
 * The BaitListManager is a utility class for managing the baits list.
 * @author Cohen Adair
 */
public class BaitListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private boolean mIsBait = true;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);
        }

        /**
         * Disable clicking if the current item isn't a Bait.
         */

        @Override
        public boolean onLongClick(View view) {
            return !mIsBait || super.onLongClick(view);
        }

        @Override
        public void onClick(View v) {
            if (!mIsBait)
                return;

            super.onClick(v);
        }

        public void setBait(Bait bait) {
            initForNormalLayout();

            setTitle(bait.getName());
            setSubtitle(bait.getCategoryName());
            setImage(bait.getRandomPhoto());

            if (!getAdapter().isCondensed()) {
                getFavoriteStar().setVisibility(View.GONE);
                setSubSubtitle(bait.getCatchCountAsString(getContext()));
            }

            updateViews();
            mIsBait = true;
        }

        public void setBaitCategory(BaitCategory category) {
            initForHeaderLayout();
            setHeaderText(category.getName());
            mIsBait = false;
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean singleSelection, boolean multiSelection, OnClickInterface callbacks) {
            super(context, items, singleSelection, multiSelection, callbacks);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean condensed, OnClickInterface callbacks) {
            super(context, items, condensed, callbacks);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, false, false, callbacks);
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
