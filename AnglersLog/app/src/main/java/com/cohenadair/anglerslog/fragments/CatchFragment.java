package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.graphics.Point;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.fragment.LayoutController;

/**
 * A {@link DetailFragment} subclass used to show the details of a single catch.
 */
public class CatchFragment extends DetailFragment {

    private Catch mCatch;

    private ViewPager mPhotoViewPager;
    private TextView mSpeciesTextView;
    private TextView mDateTextView;

    public CatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catch, container, false);

        mSpeciesTextView = (TextView)view.findViewById(R.id.species_text_view);
        mDateTextView = (TextView)view.findViewById(R.id.date_text_view);

        mPhotoViewPager = (ViewPager)view.findViewById(R.id.photo_view_pager);

        if (Logbook.catchCount() <= 0) {
            // TODO replace with "NoUserDefineView"
            mSpeciesTextView.setText("Select a catch to view it here.");
            mDateTextView.setText("");
        } else
            update(LayoutController.getSelectionPosition());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(int position) {
        setItemPosition(position);
        mCatch = Logbook.catchAtPos(position);

        mSpeciesTextView.setText(mCatch.speciesAsString());
        mDateTextView.setText(mCatch.dateAsString());

        mPhotoViewPager.setVisibility((mCatch.photoCount() > 0) ? View.VISIBLE : View.GONE);
        mPhotoViewPager.setAdapter(new CatchPagerAdapter(getContext()));
        mPhotoViewPager.setLayoutParams(new LinearLayout.LayoutParams(photoPagerSize(), photoPagerSize()));
    }

    @Override
    public void update() {
        update(getItemPosition());
    }

    private int photoPagerSize() {
        Point screenSize = Utils.getScreenSize(getActivity());
        // the image size will be the smaller of the screen width/height
        return (screenSize.x >= screenSize.y) ? screenSize.y : screenSize.x;
    }

    private class CatchPagerAdapter extends PagerAdapter {

        private Context mContext;
        private ImageView mImageView;

        public CatchPagerAdapter(Context context) {
            mContext = context;
        }

        @Override
        public Object instantiateItem(ViewGroup collection, int position) {
            LayoutInflater inflater = LayoutInflater.from(mContext);
            ViewGroup viewGroup = (ViewGroup)inflater.inflate(R.layout.view_image_pager, collection, false);

            String path = PhotoUtils.privatePhotoPath(mCatch.photoAtPos(position));
            int imageSize = photoPagerSize();

            mImageView = (ImageView)viewGroup.findViewById(R.id.image_pager_view);
            mImageView.setLayoutParams(new RelativeLayout.LayoutParams(imageSize, imageSize));
            PhotoUtils.thumbnailToImageView(mImageView, path, imageSize, R.drawable.no_catch_photo);

            collection.addView(viewGroup);
            return viewGroup;
        }

        @Override
        public void destroyItem(ViewGroup collection, int position, Object view) {
            collection.removeView((View)view);
        }

        @Override
        public int getCount() {
            return mCatch.photoCount();
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == object;
        }

    }
}
