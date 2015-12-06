package com.cohenadair.anglerslog.baits;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

import java.io.File;
import java.util.ArrayList;

/**
 * The BaitListManager is a utility class for managing the catches list.
 * Created by Cohen Adair on 2015-10-05.
 */
public class BaitListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private ListManager.Adapter mAdapter;
        private ImageView mImageView;
        private TextView mCategoryTextView;
        private TextView mNameTextView;
        private TextView mNumberCaughtTextView;
        private View mSeparator;
        private View mView;

        public ViewHolder(View view, ListManager.Adapter adapter) {
            super(view, adapter);

            mAdapter = adapter;
            mView = view;
            mImageView = (ImageView)view.findViewById(R.id.image_view);
            mCategoryTextView = (TextView)view.findViewById(R.id.category_text_view);
            mNameTextView = (TextView)view.findViewById(R.id.name_label);
            mNumberCaughtTextView = (TextView)view.findViewById(R.id.number_caught_label);
            mSeparator = view.findViewById(R.id.cell_separator);
        }

        public void setBait(Bait bait, int position) {
            mCategoryTextView.setVisibility(View.GONE);
            mNameTextView.setText(bait.getName());
            mNumberCaughtTextView.setText("0 Catches"); // TODO get actual stats here

            // thumbnail stuff
            // if the image doesn't exist or can't be read, a default icon is shown
            boolean fileExists = false;
            String randomPhoto = bait.getRandomPhoto();
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
            mView.setBackgroundResource(bait.isSelected() ? R.color.light_grey : android.R.color.transparent);
        }

        public void setBaitCategory(BaitCategory category) {
            mCategoryTextView.setText(category.getName());
            mNameTextView.setVisibility(View.GONE);
            mNumberCaughtTextView.setVisibility(View.GONE);
            mImageView.setVisibility(View.GONE);
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
            View view = inflater.inflate(R.layout.list_item_bait, parent, false);
            return new ViewHolder(view, this);
        }

        @Override
        public void onBindViewHolder(ListManager.ViewHolder holder, int position) {
            super.onBind(holder, position);

            ViewHolder baitHolder = (ViewHolder)holder;
            UserDefineObject item = getItem(position);

            if (item instanceof Bait)
                baitHolder.setBait((Bait)item, position);
            else
                baitHolder.setBaitCategory((BaitCategory)item);
        }
    }
    //endregion

}
