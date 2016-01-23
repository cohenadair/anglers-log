package com.cohenadair.anglerslog.catches;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.ImageScrollView;
import com.cohenadair.anglerslog.views.PropertyDetailView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;
import com.cohenadair.anglerslog.views.WeatherDetailsView;

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
    private PropertyDetailView mFishingMethodsView;
    private PropertyDetailView mWaterClarityView;
    private PropertyDetailView mResultView;
    private PropertyDetailView mQuantityView;
    private PropertyDetailView mLengthView;
    private PropertyDetailView mWeightView;
    private PropertyDetailView mWaterDepthView;
    private PropertyDetailView mWaterTemperatureView;
    private WeatherDetailsView mWeatherDetailsView;
    private TextView mNotesView;

    private TextView mCatchDetails;
    private TextView mFishDetails;
    private TextView mWaterConditions;
    private TextView mWeatherConditions;
    private TextView mNotesTitle;

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
        mFishingMethodsView = (PropertyDetailView)view.findViewById(R.id.fishing_methods_view);
        mWaterClarityView = (PropertyDetailView)view.findViewById(R.id.water_clarity_view);
        mResultView = (PropertyDetailView)view.findViewById(R.id.catch_result_view);
        mLengthView = (PropertyDetailView)view.findViewById(R.id.length_view);
        mWeightView = (PropertyDetailView)view.findViewById(R.id.weight_view);
        mQuantityView = (PropertyDetailView)view.findViewById(R.id.quantity_view);
        mWaterDepthView = (PropertyDetailView)view.findViewById(R.id.water_depth_view);
        mWaterTemperatureView = (PropertyDetailView)view.findViewById(R.id.water_temperature_view);
        mWeatherDetailsView = (WeatherDetailsView)view.findViewById(R.id.weather_details_view);
        mNotesView = (TextView)view.findViewById(R.id.notes_text_view);

        mCatchDetails = (TextView)view.findViewById(R.id.title_catch_details);
        mFishDetails = (TextView)view.findViewById(R.id.title_fish_details);
        mWaterConditions = (TextView)view.findViewById(R.id.title_water_conditions);
        mWeatherConditions = (TextView)view.findViewById(R.id.title_weather_conditions);
        mNotesTitle = (TextView)view.findViewById(R.id.title_notes);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        // if there are no catches, there is nothing to display
        // this really only applies to the two-pane view
        if (Logbook.getCatchCount() <= 0) {
            View container = getView();
            if (container != null)
                container.setVisibility(View.GONE);
            return;
        }

        setItemId(id);
        mCatch = Logbook.getCatch(id);

        if (mCatch == null)
            return;

        mCatchPhotos = mCatch.getPhotos();
        mImageScrollView.setImages(mCatchPhotos);

        updateTitleView();
        updateBaitView();
        updateLocationView();
        updateFishingMethodsView();
        updateWaterClarityView();
        updateResultView();
        updateWeatherDetailsView();
        updateQuantityView();
        updateLengthView();
        updateWeightView();
        updateWaterDepthView();
        updateWaterTemperatureView();
        updateNotesView();

        // hide catch details title if needed
        if (mCatch.getBait() == null && mCatch.getFishingSpot() == null && mCatch.getFishingMethods().size() <= 0)
            mCatchDetails.setVisibility(View.GONE);

        // hide fish details title if needed
        if (mCatch.getCatchResult() == null && mCatch.getQuantity() == -1 && mCatch.getLength() == -1 && mCatch.getWeight() == -1)
            mFishDetails.setVisibility(View.GONE);

        // hide water conditions title if needed
        if (mCatch.getWaterClarity() == null && mCatch.getWaterDepth() == -1 && mCatch.getWaterTemperature() == -1)
            mWaterConditions.setVisibility(View.GONE);

        // hide weather title if needed
        if (mCatch.getWeather() == null)
            mWeatherConditions.setVisibility(View.GONE);

        // hide notes title if needed
        if (mCatch.getNotes() == null)
            mNotesTitle.setVisibility(View.GONE);
    }

    private void updateTitleView() {
        mTitleView.setTitle(mCatch.getSpeciesAsString());
        mTitleView.setSubtitle(mCatch.getDateTimeAsString());
    }

    private void updateBaitView() {
        Utils.toggleVisibility(mBaitLayout, mCatch.getBait() != null);
        mBaitView.setSubtitle(mCatch.getBaitAsString());
    }

    private void updateLocationView() {
        Utils.toggleVisibility(mLocationLayout, mCatch.getFishingSpot() != null);
        mLocationView.setSubtitle(mCatch.getFishingSpotAsString());
    }

    private void updateFishingMethodsView() {
        Utils.toggleVisibility(mFishingMethodsView, mCatch.hasFishingMethods());
        mFishingMethodsView.setDetail(mCatch.getFishingMethodsAsString());
    }

    private void updateWaterClarityView() {
        Utils.toggleVisibility(mWaterClarityView, mCatch.getWaterClarity() != null);
        mWaterClarityView.setDetail(mCatch.getWaterClarityAsString());
    }

    private void updateResultView() {
        Utils.toggleVisibility(mResultView, mCatch.getCatchResult() != null);
        mResultView.setDetail(mCatch.getCatchResultAsString(getContext()));
    }

    private void updateWeatherDetailsView() {
        Weather weather = mCatch.getWeather();
        Utils.toggleVisibility(mWeatherDetailsView, weather != null);
        mWeatherDetailsView.updateViews(weather);
    }

    private void updateQuantityView() {
        Utils.toggleVisibility(mQuantityView, mCatch.getQuantity() != -1);
        mQuantityView.setDetail(mCatch.getQuantityAsString());
    }

    private void updateLengthView() {
        Utils.toggleVisibility(mLengthView, mCatch.getLength() != -1);
        mLengthView.setDetail(mCatch.getLengthAsString(getContext()));
    }

    private void updateWeightView() {
        Utils.toggleVisibility(mWeightView, mCatch.getWeight() != -1);
        mWeightView.setDetail(mCatch.getWeightAsString(getContext()));
    }

    private void updateWaterDepthView() {
        Utils.toggleVisibility(mWaterDepthView, mCatch.getWaterDepth() != -1);
        mWaterDepthView.setDetail(mCatch.getWaterDepthAsString(getContext()));
    }

    private void updateWaterTemperatureView() {
        Utils.toggleVisibility(mWaterTemperatureView, mCatch.getWaterTemperature() != -1);
        mWaterTemperatureView.setDetail(mCatch.getWaterTemperatureAsString(getContext()));
    }

    private void updateNotesView() {
        Utils.toggleVisibility(mNotesView, mCatch.getNotes() != null);
        mNotesView.setText(mCatch.getNotesAsString());
    }

    private void initLocationLayout(View view) {
        mLocationLayout = (LinearLayout)view.findViewById(R.id.location_layout);
        mLocationView =(TitleSubTitleView)view.findViewById(R.id.location_view);

        ImageButton locationInfoButton = (ImageButton)view.findViewById(R.id.location_info_button);
        locationInfoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, mCatch.getFishingSpot().getId());
            }
        });
    }

    private void initBaitLayout(View view) {
        mBaitLayout = (LinearLayout)view.findViewById(R.id.bait_layout);
        mBaitView =(TitleSubTitleView)view.findViewById(R.id.bait_view);

        ImageButton baitIntoButton = (ImageButton)view.findViewById(R.id.bait_info_button);
        baitIntoButton.setOnClickListener(new View.OnClickListener() {
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
