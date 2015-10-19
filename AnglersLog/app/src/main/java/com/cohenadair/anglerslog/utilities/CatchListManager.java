package com.cohenadair.anglerslog.utilities;

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
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.io.File;
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
        private View mSeparator;

        private Catch mCatch;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mImageView = (ImageView)view.findViewById(R.id.image_view);
            mSpeciesTextView = (TextView)view.findViewById(R.id.species_label);
            mDateTextView = (TextView)view.findViewById(R.id.date_label);
            mSeparator = view.findViewById(R.id.cell_separator);

            mFavorite = (RatingBar)view.findViewById(R.id.favorite_star);
            mFavorite.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    // TODO make custom view for FavoriteStar
                    if (event.getAction() == MotionEvent.ACTION_UP) {
                        mFavorite.setRating(mFavorite.getRating() <= 0 ? (float) 1.0 : (float) 0.0);
                        mCatch.setIsFavorite(mFavorite.getRating() > 0);
                    }
                    return true;
                }
            });
        }

        @Override
        public void onItemEdit(int position) {
            ((OnClickManageMenuListener)context()).onClickMenuEdit(position);
        }

        @Override
        public void onItemDelete(int position) {
            ((OnClickManageMenuListener)context()).onClickMenuTrash(position);
        }

        public void setCatch(Catch aCatch, int position) {
            mCatch = aCatch;
            mSpeciesTextView.setText(aCatch.speciesAsString());
            mDateTextView.setText(aCatch.dateTimeAsString());
            mFavorite.setRating(mCatch.isFavorite() ? (float) 1.0 : (float) 0.0);

            // thumbnail stuff
            // if the image doesn't exist or can't be read, a default icon is shown
            boolean fileExists = false;
            String randomPhoto = mCatch.randomPhoto();
            String randomPhotoPath = "";

            if (randomPhoto != null)
                randomPhotoPath = PhotoUtils.photoPath(context(), randomPhoto);

            if (randomPhotoPath != null)
                fileExists = new File(randomPhotoPath).exists();
            else
                mCatch.removePhoto(randomPhoto); // remove photo name from the Catch if the file doesn't exist

            if (fileExists) {
                int thumbSize = context().getResources().getDimensionPixelSize(R.dimen.thumbnail_size);
                PhotoUtils.thumbnailToImageView(context(), mImageView, randomPhotoPath, thumbSize, R.drawable.no_catch_photo);
            } else
                mImageView.setImageResource(R.drawable.no_catch_photo);

            // hide the separator for the last row
            mSeparator.setVisibility((position == Logbook.catchCount() - 1) ? View.INVISIBLE : View.VISIBLE);
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
            catchHolder.setCatch((Catch)itemAtPos(position), position);
        }
    }
    //endregion

}
