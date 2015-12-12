package com.cohenadair.anglerslog.catches;

import android.content.Context;
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
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

import java.io.File;
import java.util.ArrayList;

/**
 * The BaitListManager is a utility class for managing the catches list.
 * Created by Cohen Adair on 2015-10-05.
 */
public class CatchListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ListManager.Adapter mAdapter;
        private ImageView mImageView;
        private TextView mSpeciesTextView;
        private TextView mDateTextView;
        private TextView mLocationTextView;
        private RatingBar mFavorite;
        private View mSeparator;
        private View mView;

        private Catch mCatch;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mView = view;
            mAdapter = adapter;
            mImageView = (ImageView)view.findViewById(R.id.image_view);
            mSpeciesTextView = (TextView)view.findViewById(R.id.species_label);
            mDateTextView = (TextView)view.findViewById(R.id.date_label);
            mLocationTextView = (TextView)view.findViewById(R.id.location_label);
            mSeparator = view.findViewById(R.id.cell_separator);

            mFavorite = (RatingBar)view.findViewById(R.id.favorite_star);
            mFavorite.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    // TODO make custom view for FavoriteStar
                    if (event.getAction() == MotionEvent.ACTION_UP) {
                        mFavorite.setRating(mFavorite.getRating() <= 0 ? (float) 1.0 : (float) 0.0);
                        mCatch.setIsFavorite(mFavorite.getRating() > 0);
                        Logbook.editCatch(mCatch.getId(), mCatch);
                    }
                    return true;
                }
            });
        }

        public void setCatch(Catch aCatch, int position) {
            mCatch = aCatch;

            mSpeciesTextView.setText(aCatch.getSpeciesAsString());
            mDateTextView.setText(aCatch.getDateTimeAsString());
            mFavorite.setRating(mCatch.isFavorite() ? (float) 1.0 : (float) 0.0);

            if (aCatch.getFishingSpot() != null)
                mLocationTextView.setText(aCatch.getFishingSpotAsString());
            else
                mLocationTextView.setVisibility(View.GONE);

            // thumbnail stuff
            // if the image doesn't exist or can't be read, a default icon is shown
            boolean fileExists = false;
            String randomPhoto = mCatch.getRandomPhoto();
            String randomPhotoPath = "";

            if (randomPhoto != null)
                randomPhotoPath = PhotoUtils.privatePhotoPath(randomPhoto);

            if (randomPhotoPath != null)
                fileExists = new File(randomPhotoPath).exists();

            if (fileExists) {
                int thumbSize = context().getResources().getDimensionPixelSize(R.dimen.thumbnail_size);
                PhotoUtils.thumbnailToImageView(mImageView, randomPhotoPath, thumbSize, R.drawable.no_catch_photo);
            } else
                mImageView.setImageResource(R.drawable.no_catch_photo);

            // hide the separator for the last row
            mSeparator.setVisibility((position == mAdapter.getItemCount() - 1) ? View.INVISIBLE : View.VISIBLE);
            mView.setBackgroundResource(mCatch.isSelected() ? R.color.light_grey : android.R.color.transparent);
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, callbacks);
        }

        // can't be overridden in the superclass because it needs to return a BaitListManager.ViewHolder
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
            catchHolder.setCatch((Catch)getItem(position), position);
        }
    }
    //endregion

}
