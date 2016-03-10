package com.cohenadair.anglerslog.catches;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RatingBar;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.io.File;
import java.util.ArrayList;

/**
 * The BaitListManager is a utility class for managing the catches list.
 * Created by Cohen Adair on 2015-10-05.
 */
public class CatchListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ImageView mImageView;
        private TitleSubTitleView mTitleSubTitleView;
        private RatingBar mFavorite;
        private View mSeparator;
        private CatchListManager.Adapter.GetContentListener mListener;

        private Catch mCatch;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mImageView = (ImageView)view.findViewById(R.id.image_view);
            mTitleSubTitleView = (TitleSubTitleView)view.findViewById(R.id.content_view);
            mSeparator = view.findViewById(R.id.cell_separator);
            mListener = ((CatchListManager.Adapter)getAdapter()).getGetContentListener();

            mFavorite = (RatingBar)view.findViewById(R.id.favorite_star);
            mFavorite.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
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

            mTitleSubTitleView.setTitle(aCatch.getSpeciesAsString());
            mTitleSubTitleView.setSubtitle(aCatch.getDateTimeAsString());
            mFavorite.setRating(mCatch.isFavorite() ? (float) 1.0 : (float) 0.0);

            if (aCatch.getFishingSpot() != null)
                mTitleSubTitleView.setSubSubtitle((mListener == null) ? aCatch.getFishingSpotAsString() : mListener.onGetSubSubtitle(mCatch));
            else
                mTitleSubTitleView.hideSubSubtitle();

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

            updateView(mSeparator, position, mCatch);
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        private GetContentListener mGetContentListener;

        public interface GetContentListener {
            String onGetSubSubtitle(Catch aCatch);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, callbacks);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface onClickView, GetContentListener onGetContent) {
            super(context, items, onClickView);
            mGetContentListener = onGetContent;
        }

        public GetContentListener getGetContentListener() {
            return mGetContentListener;
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
            catchHolder.setCatch((Catch)getItem(position), position);
        }
    }
    //endregion

}
