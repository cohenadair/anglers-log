package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

import java.util.ArrayList;

/**
 * The PhotoViewerFragment is used to view full images in a horizontal scrolling
 * {@link android.support.v4.view.ViewPager}.
 *
 * @author Cohen Adair
 */
public class PhotoViewerFragment extends Fragment {

    private ArrayList<String> mPhotoNames;
    private int mStartIndex = 0;

    public PhotoViewerFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_photo_viewer, container, false);

        ViewPager viewPager = (ViewPager)view.findViewById(R.id.photo_view_pager);
        viewPager.setAdapter(new PhotoViewerAdapter());
        viewPager.setCurrentItem(mStartIndex);

        return view;
    }

    public void setPhotoNames(ArrayList<String> photoNames) {
        mPhotoNames = photoNames;
    }

    public void setStartIndex(int startIndex) {
        mStartIndex = startIndex;
    }

    private class PhotoViewerAdapter extends PagerAdapter {

        private ImageView mImageView;

        public PhotoViewerAdapter() {

        }

        @Override
        public Object instantiateItem(ViewGroup collection, int position) {
            LayoutInflater inflater = LayoutInflater.from(PhotoViewerFragment.this.getContext());
            ViewGroup viewGroup = (ViewGroup)inflater.inflate(R.layout.view_image_pager, collection, false);

            String path = PhotoUtils.privatePhotoPath(mPhotoNames.get(position));

            mImageView = (ImageView)viewGroup.findViewById(R.id.image_pager_view);
            mImageView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                }
            });

            PhotoUtils.photoToImageView(mImageView, path);

            collection.addView(viewGroup);
            return viewGroup;
        }

        @Override
        public void destroyItem(ViewGroup collection, int position, Object view) {
            collection.removeView((View)view);
        }

        @Override
        public int getCount() {
            return mPhotoNames.size();
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == object;
        }

    }
}
