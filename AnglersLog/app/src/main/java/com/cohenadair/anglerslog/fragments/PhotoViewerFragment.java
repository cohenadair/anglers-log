package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateInterpolator;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

/**
 * The PhotoViewerFragment is used to view full images in a horizontal scrolling
 * {@link android.support.v4.view.ViewPager}.
 *
 * @author Cohen Adair
 */
public class PhotoViewerFragment extends Fragment {

    private RelativeLayout mToolbar;

    private ArrayList<String> mPhotoNames;
    private int mStartIndex = 0;

    public PhotoViewerFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_photo_viewer, container, false);

        Utils.allowSystemOverlay(getActivity());

        // toggle the toolbar when system components are toggled
        getActivity().getWindow().getDecorView().setOnSystemUiVisibilityChangeListener(new View.OnSystemUiVisibilityChangeListener() {
            @Override
            public void onSystemUiVisibilityChange(int visibility) {
                toggleToolbar((visibility & View.SYSTEM_UI_FLAG_FULLSCREEN) == 0);
            }
        });

        initToolbar(view);
        initViewPager(view);

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();

        // delay hidden UI
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                Utils.toggleSystemUI(getActivity(), false);
            }
        }, 1500);
    }

    private void initToolbar(View view) {
        mToolbar = (RelativeLayout)view.findViewById(R.id.toolbar);

        // compensate for the status bar
        // this is needed because the System UI components are hidden and content is set to
        // display below it
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, Utils.getStatusBarHeight(getContext()), 0, 0);
        mToolbar.setLayoutParams(params);

        ImageButton back = (ImageButton)view.findViewById(R.id.back_button);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getActivity().finish();
            }
        });

        ImageButton share = (ImageButton)view.findViewById(R.id.share_button);
        share.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
    }

    private void initViewPager(View view) {
        ViewPager viewPager = (ViewPager)view.findViewById(R.id.photo_view_pager);
        viewPager.setAdapter(new PhotoViewerAdapter());
        viewPager.setCurrentItem(mStartIndex);
    }

    public void setPhotoNames(ArrayList<String> photoNames) {
        mPhotoNames = photoNames;
    }

    public void setStartIndex(int startIndex) {
        mStartIndex = startIndex;
    }

    private void animateToolbar(float y) {
        mToolbar.animate().translationY(y).setInterpolator(new AccelerateInterpolator()).start();
    }

    private void showToolbar() {
        animateToolbar(0);
    }

    private void hideToolbar() {
        animateToolbar(-(mToolbar.getHeight() + Utils.getStatusBarHeight(getContext())));
    }

    private void toggleToolbar(boolean show) {
        if (show)
            showToolbar();
        else
            hideToolbar();
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
                    Utils.toggleSystemUI(getActivity(), mToolbar.getY() < 0);
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
