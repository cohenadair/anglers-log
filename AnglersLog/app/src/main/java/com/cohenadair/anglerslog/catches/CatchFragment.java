package com.cohenadair.anglerslog.catches;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.ImageScrollView;
import com.cohenadair.anglerslog.views.MoreDetailView;
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

    private LinearLayout mContainer;
    private ImageScrollView mImageScrollView;
    private TitleSubTitleView mTitleView;
    private MoreDetailView mBaitView;
    private MoreDetailView mLocationView;
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

        mContainer = (LinearLayout)view.findViewById(R.id.catch_container);

        mImageScrollView = (ImageScrollView)view.findViewById(R.id.image_scroll_view);
        mImageScrollView.setInteractionListener(new ImageScrollView.InteractionListener() {
            @Override
            public void onImageClick(int position) {
                startActivity(PhotoViewerActivity.getIntent(getContext(), mCatchPhotos, position));
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

        // id can be null if in two-pane view and there are no catches
        if (id == null) {
            mContainer.setVisibility(View.GONE);
            return;
        }

        setItemId(id);
        mCatch = Logbook.getCatch(id);

        // mCatch can be null if in tw-pane view and a catch was removed
        if (mCatch == null) {
            mContainer.setVisibility(View.GONE);
            return;
        }

        mContainer.setVisibility(View.VISIBLE);
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
        updateHeadingViews();
    }

    private void updateTitleView() {
        mTitleView.setTitle(mCatch.getSpeciesAsString());
        mTitleView.setSubtitle(mCatch.getDateTimeAsString());
    }

    private void updateBaitView() {
        Utils.toggleVisibility(mBaitView, mCatch.getBait() != null);
        mBaitView.setSubtitle(mCatch.getBaitAsString());
    }

    private void updateLocationView() {
        Utils.toggleVisibility(mLocationView, mCatch.getFishingSpot() != null);
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
        mLengthView.setDetail(mCatch.getLengthAsStringWithUnits());
    }

    private void updateWeightView() {
        Utils.toggleVisibility(mWeightView, mCatch.getWeight() != -1);
        mWeightView.setDetail(mCatch.getWeightAsStringWithUnits());
    }

    private void updateWaterDepthView() {
        Utils.toggleVisibility(mWaterDepthView, mCatch.getWaterDepth() != -1);
        mWaterDepthView.setDetail(mCatch.getWaterDepthAsStringWithUnits());
    }

    private void updateWaterTemperatureView() {
        Utils.toggleVisibility(mWaterTemperatureView, mCatch.getWaterTemperature() != -1);
        mWaterTemperatureView.setDetail(mCatch.getWaterTemperatureAsStringWithUnits());
    }

    private void updateNotesView() {
        Utils.toggleVisibility(mNotesView, mCatch.getNotes() != null);
        mNotesView.setText(mCatch.getNotesAsString());
    }

    /**
     * Toggles the visibility of the heading views.
     */
    private void updateHeadingViews() {
        Utils.toggleVisibility(mCatchDetails, mCatch.getBait() != null || mCatch.getFishingSpot() != null || mCatch.getFishingMethods().size() > 0);
        Utils.toggleVisibility(mFishDetails, mCatch.getCatchResult() != null || mCatch.getQuantity() != -1 || mCatch.getLength() != -1 || mCatch.getWeight() != -1);
        Utils.toggleVisibility(mWaterConditions, mCatch.getWaterClarity() != null || mCatch.getWaterDepth() != -1 || mCatch.getWaterTemperature() != -1);
        Utils.toggleVisibility(mWeatherConditions, mCatch.getWeather() != null);
        Utils.toggleVisibility(mNotesTitle, mCatch.getNotes() != null && !mCatch.getNotes().isEmpty());
    }

    private void initLocationLayout(View view) {
        mLocationView = (MoreDetailView)view.findViewById(R.id.location_view);
        mLocationView.setOnClickDetailButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, mCatch.getFishingSpot().getId());
            }
        });
    }

    private void initBaitLayout(View view) {
        mBaitView = (MoreDetailView)view.findViewById(R.id.bait_view);
        mBaitView.setOnClickDetailButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_BAITS, mCatch.getBait().getId());
            }
        });
    }
}
