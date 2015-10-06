package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;

/**
 * The CatchListManager is a utility class for managing the catches list.
 * Created by Cohen Adair on 2015-10-05.
 */
public class CatchListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ImageView mImageView;
        private TextView mSpeciesTextView;
        private TextView mDateTextView;
        private RatingBar mFavorite;

        private Catch mCatch;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mImageView = (ImageView)view.findViewById(R.id.image_view);
            mSpeciesTextView = (TextView)view.findViewById(R.id.species_label);
            mDateTextView = (TextView)view.findViewById(R.id.date_label);

            mFavorite = (RatingBar)view.findViewById(R.id.favorite_star);
            mFavorite.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    // TODO make custom view for FavoriteStar
                    if (event.getAction() == MotionEvent.ACTION_UP) {
                        mFavorite.setRating(mFavorite.getRating() <= 0 ? (float)1.0 : (float)0.0);
                        mCatch.setIsFavorite(mFavorite.getRating() > 0);
                    }
                    return true;
                }
            });
        }

        @Override
        public void onItemEdit(int position) {
            Log.d("", "Clicked edit! " + position);
        }

        @Override
        public void onItemDelete(int position) {
            Utils.showDeleteConfirm(context(), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    Logbook.getInstance().removeCatch(mCatch);
                    getAdapter().notifyDataSetChanged();
                    Utils.showToast(context(), R.string.success_catch_delete);
                }
            });
        }

        public void setCatch(Catch aCatch) {
            mCatch = aCatch;
            mSpeciesTextView.setText(aCatch.speciesAsString());
            mDateTextView.setText(aCatch.dateTimeAsString());
            mFavorite.setRating(mCatch.isFavorite() ? (float)1.0 : (float)0.0);
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, callbacks);
        }

        // can't be overridden in the superclass because it needs to return a CatchListManager.ViewHolder
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            View view = inflater.inflate(R.layout.list_item_catch, parent, false);
            return new ViewHolder(view, this);
        }

        @Override
        public void onBindViewHolder(ListManager.ViewHolder holder, int position) {
            super.onBind(holder, position);

            ViewHolder catchHolder = (ViewHolder)holder;
            catchHolder.setCatch((Catch) itemAtPos(position));
        }
    }
    //endregion

}
