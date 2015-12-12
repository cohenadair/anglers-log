package com.cohenadair.anglerslog.catches;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.ImageScrollView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single catch.
 */
public class CatchFragment extends DetailFragment {

    private Catch mCatch;
    private ArrayList<String> mCatchPhotos;

    private ImageScrollView mImageScrollView;
    private TitleSubTitleView mTitleView;
    private LinearLayout mLocationLayout;
    private LinearLayout mBaitLayout;
    private TitleSubTitleView mLocationView;
    private TitleSubTitleView mBaitView;
    private ImageButton mLocationInfoButton;
    private ImageButton mBaitInfoButton;

    public CatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catch, container, false);

        mImageScrollView = (ImageScrollView)view.findViewById(R.id.image_scroll_view);
        mImageScrollView.setInteractionListener(new ImageScrollView.InteractionListener() {
            @Override
            public void onImageClick(int position) {
                Intent intent = new Intent(getContext(), PhotoViewerActivity.class);
                intent.putStringArrayListExtra(PhotoViewerActivity.EXTRA_NAMES, mCatchPhotos);
                intent.putExtra(PhotoViewerActivity.EXTRA_CURRENT, position);
                startActivity(intent);
            }
        });

        initLocationLayout(view);
        initBaitLayout(view);

        mTitleView = (TitleSubTitleView)view.findViewById(R.id.title_view);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        if (Logbook.getCatchCount() <= 0) {
            mTitleView.setVisibility(View.GONE);
        } else {
            setItemId(id);
            mCatch = Logbook.getCatch(id);

            if (mCatch != null) {
                mCatchPhotos = mCatch.getPhotos();

                mImageScrollView.setImages(mCatchPhotos);
                mTitleView.setTitle(mCatch.getSpeciesAsString());
                mTitleView.setSubtitle(mCatch.getDateTimeAsString());

                mBaitLayout.setVisibility((mCatch.getBait() != null) ? View.VISIBLE : View.GONE);
                if (mCatch.getBait() != null)
                    mBaitView.setSubtitle(mCatch.getBaitAsString());

                mLocationLayout.setVisibility((mCatch.getFishingSpot() != null) ? View.VISIBLE : View.GONE);
                if (mCatch.getFishingSpot() != null)
                    mLocationView.setSubtitle(mCatch.getFishingSpotAsString());
            }
        }
    }

    private void initLocationLayout(View view) {
        mLocationLayout = (LinearLayout)view.findViewById(R.id.location_layout);
        mLocationView =(TitleSubTitleView)view.findViewById(R.id.location_view);

        mLocationInfoButton = (ImageButton)view.findViewById(R.id.location_info_button);
        mLocationInfoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, mCatch.getFishingSpot().getId());
            }
        });
    }

    private void initBaitLayout(View view) {
        mBaitLayout = (LinearLayout)view.findViewById(R.id.bait_layout);
        mBaitView =(TitleSubTitleView)view.findViewById(R.id.bait_view);

        mBaitInfoButton = (ImageButton)view.findViewById(R.id.bait_info_button);
        mBaitInfoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_BAITS, mCatch.getBait().getId());
            }
        });
    }

    private void startDetailActivity(int layoutSpecId, UUID userDefineObjectId) {
        Intent intent = new Intent(getContext(), DetailFragmentActivity.class);
        intent.putExtra(DetailFragmentActivity.EXTRA_TWO_PANE, Utils.isTwoPane(getActivity()));
        intent.putExtra(DetailFragmentActivity.EXTRA_LAYOUT_ID, layoutSpecId);
        intent.putExtra(DetailFragmentActivity.EXTRA_USER_DEFINE_ID, userDefineObjectId.toString());
        startActivity(intent);
    }
}
