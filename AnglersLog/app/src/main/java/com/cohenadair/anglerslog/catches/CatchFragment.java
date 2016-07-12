package com.cohenadair.anglerslog.catches;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.DisplayLabelView;
import com.cohenadair.anglerslog.views.ImageScrollView;
import com.cohenadair.anglerslog.views.WeatherDetailsView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single catch.
 * @author Cohen Adair
 */
public class CatchFragment extends DetailFragment {

    private Catch mCatch;
    private ArrayList<String> mCatchPhotos;

    private ImageScrollView mImageScrollView;
    private DisplayLabelView mSpeciesView;
    private DisplayLabelView mDateView;
    private DisplayLabelView mBaitView;
    private DisplayLabelView mLocationView;
    private DisplayLabelView mFishingMethodsView;
    private DisplayLabelView mWaterClarityView;
    private DisplayLabelView mResultView;
    private DisplayLabelView mQuantityView;
    private DisplayLabelView mLengthView;
    private DisplayLabelView mWeightView;
    private DisplayLabelView mWaterDepthView;
    private DisplayLabelView mWaterTemperatureView;
    private DisplayLabelView mNotesView;
    private LinearLayout mWeatherContainer;
    private WeatherDetailsView mWeatherDetailsView;

    // need to be hidden if certain fields weren't filled out
    private LinearLayout mSizeContainer;
    private LinearLayout mWaterContainer;

    public CatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catch, container, false);

        setContainer((LinearLayout)view.findViewById(R.id.catch_container));

        mImageScrollView = (ImageScrollView)view.findViewById(R.id.image_scroll_view);
        mImageScrollView.setInteractionListener(new ImageScrollView.InteractionListener() {
            @Override
            public void onImageClick(int position) {
                startActivity(PhotoViewerActivity.getIntent(getContext(), mCatchPhotos, position));
            }
        });

        initLocationLayout(view);
        initBaitLayout(view);

        mSpeciesView = (DisplayLabelView)view.findViewById(R.id.species_view);
        mDateView= (DisplayLabelView)view.findViewById(R.id.date_view);
        mFishingMethodsView = (DisplayLabelView)view.findViewById(R.id.fishing_methods_view);
        mWaterClarityView = (DisplayLabelView)view.findViewById(R.id.water_clarity_view);
        mResultView = (DisplayLabelView)view.findViewById(R.id.catch_result_view);
        mLengthView = (DisplayLabelView)view.findViewById(R.id.length_view);
        mWeightView = (DisplayLabelView)view.findViewById(R.id.weight_view);
        mQuantityView = (DisplayLabelView)view.findViewById(R.id.quantity_view);
        mWaterDepthView = (DisplayLabelView)view.findViewById(R.id.water_depth_view);
        mWaterTemperatureView = (DisplayLabelView)view.findViewById(R.id.water_temperature_view);
        mNotesView = (DisplayLabelView)view.findViewById(R.id.notes_view);
        mWeatherContainer = (LinearLayout)view.findViewById(R.id.weather_container);
        mWeatherDetailsView = (WeatherDetailsView)view.findViewById(R.id.weather_details_view);

        mSizeContainer = (LinearLayout)view.findViewById(R.id.size_container);
        mWaterContainer = (LinearLayout)view.findViewById(R.id.water_container);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        clearActionBarTitle();

        // id can be null if in two-pane view and there are no catches
        if (id == null) {
            hide();
            return;
        }

        setItemId(id);
        mCatch = Logbook.getCatch(id);

        // mCatch can be null if in tw-pane view and a catch was removed
        if (mCatch == null) {
            hide();
            return;
        }

        show();
        mCatchPhotos = mCatch.getPhotos();
        mImageScrollView.setImages(mCatchPhotos);

        updateSpeciesView();
        updateDateView();
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

        updateRulerIcon();
        updateWaterIcon();
    }

    private void updateSpeciesView() {
        mSpeciesView.setDetail(mCatch.getSpeciesAsString());
    }

    private void updateDateView() {
        mDateView.setDetail(mCatch.getDateTimeAsString());
    }

    private void updateBaitView() {
        ViewUtils.setVisibility(mBaitView, mCatch.getBait() != null);
        mBaitView.setDetail(mCatch.getBaitAsString());
    }

    private void updateLocationView() {
        ViewUtils.setVisibility(mLocationView, mCatch.getFishingSpot() != null);
        mLocationView.setDetail(mCatch.getFishingSpotAsString());
    }

    private void updateFishingMethodsView() {
        ViewUtils.setVisibility(mFishingMethodsView, mCatch.hasFishingMethods());
        mFishingMethodsView.setDetail(mCatch.getFishingMethodsAsString());
    }

    private void updateWaterClarityView() {
        ViewUtils.setVisibility(mWaterClarityView, mCatch.getWaterClarity() != null);
        mWaterClarityView.setDetail(mCatch.getWaterClarityAsString());
    }

    private void updateResultView() {
        ViewUtils.setVisibility(mResultView, mCatch.getCatchResult() != null);
        mResultView.setDetail(mCatch.getCatchResultAsString(getContext()));
    }

    private void updateWeatherDetailsView() {
        Weather weather = mCatch.getWeather();
        ViewUtils.setVisibility(mWeatherContainer, weather != null);
        mWeatherDetailsView.updateViews(weather);
    }

    private void updateQuantityView() {
        ViewUtils.setVisibility(mQuantityView, mCatch.getQuantity() != -1);
        mQuantityView.setDetail(mCatch.getQuantityAsString());
    }

    private void updateLengthView() {
        ViewUtils.setVisibility(mLengthView, mCatch.getLength() != -1);
        mLengthView.setDetail(mCatch.getLengthAsStringWithUnits());
    }

    private void updateWeightView() {
        ViewUtils.setVisibility(mWeightView, mCatch.getWeight() != -1);
        mWeightView.setDetail(mCatch.getWeightAsStringWithUnits());
    }

    private void updateWaterDepthView() {
        ViewUtils.setVisibility(mWaterDepthView, mCatch.getWaterDepth() != -1);
        mWaterDepthView.setDetail(mCatch.getWaterDepthAsStringWithUnits());
    }

    private void updateWaterTemperatureView() {
        ViewUtils.setVisibility(mWaterTemperatureView, mCatch.getWaterTemperature() != -1);
        mWaterTemperatureView.setDetail(mCatch.getWaterTemperatureAsStringWithUnits());
    }

    private void updateNotesView() {
        ViewUtils.setVisibility(mNotesView, mCatch.getNotes() != null);
        mNotesView.setDetail(mCatch.getNotesAsString());
    }

    private void updateRulerIcon() {
        ViewUtils.setVisibility(mSizeContainer, !(isGone(mLengthView) && isGone(mWeightView) && isGone(mQuantityView)));
    }

    private void updateWaterIcon() {
        ViewUtils.setVisibility(mWaterContainer, !(isGone(mWaterClarityView) && isGone(mWaterDepthView) && isGone(mWaterTemperatureView)));
    }

    private boolean isGone(View view) {
        return view.getVisibility() == View.GONE;
    }

    private void initLocationLayout(View view) {
        mLocationView = (DisplayLabelView)view.findViewById(R.id.location_view);
        mLocationView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_LOCATIONS, mCatch.getFishingSpot().getId());
            }
        });
    }

    private void initBaitLayout(View view) {
        mBaitView = (DisplayLabelView)view.findViewById(R.id.bait_view);
        mBaitView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startDetailActivity(LayoutSpecManager.LAYOUT_BAITS, mCatch.getBait().getId());
            }
        });
    }
}
