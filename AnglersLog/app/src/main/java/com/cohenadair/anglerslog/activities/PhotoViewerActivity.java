package com.cohenadair.anglerslog.activities;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

import java.util.ArrayList;

public class PhotoViewerActivity extends AppCompatActivity {

    public static final String EXTRA_NAMES = "extra_names";
    public static final String EXTRA_CURRENT = "extra_current";

    private ArrayList<String> mPhotoNames;

    public static Intent getIntent(Context context, ArrayList<String> photos, int position) {
        Intent intent = new Intent(context, PhotoViewerActivity.class);
        intent.putStringArrayListExtra(PhotoViewerActivity.EXTRA_NAMES, photos);
        intent.putExtra(PhotoViewerActivity.EXTRA_CURRENT, position);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo_viewer);

        mPhotoNames = getIntent().getStringArrayListExtra(EXTRA_NAMES);

        ViewPager viewPager = (ViewPager)findViewById(R.id.photo_view_pager);
        viewPager.setAdapter(new PhotoViewerAdapter());
        viewPager.setCurrentItem(getIntent().getIntExtra(EXTRA_CURRENT, 0));
    }

    private class PhotoViewerAdapter extends PagerAdapter {

        private ImageView mImageView;

        public PhotoViewerAdapter() {

        }

        @Override
        public Object instantiateItem(ViewGroup collection, int position) {
            LayoutInflater inflater = LayoutInflater.from(PhotoViewerActivity.this);
            ViewGroup viewGroup = (ViewGroup)inflater.inflate(R.layout.view_image_pager, collection, false);

            String path = PhotoUtils.privatePhotoPath(mPhotoNames.get(position));

            mImageView = (ImageView)viewGroup.findViewById(R.id.image_pager_view);
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
