package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Weather;
import com.squareup.picasso.Picasso;

/**
 * A WeatherView is a view that used for getting, displaying, and managing weather data.
 * Created by Cohen Adair on 2016-01-13.
 */
public class WeatherView extends LinearLayout {

    private ImageButton mRefreshButton;
    private ImageView mImage;
    private TextView mTemperatureTextView;
    private TextView mWindTextView;
    private TextView mSkyTextView;

    public WeatherView(Context context) {
        this(context, null);
        init(null);
    }

    public WeatherView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_weather_editor, this);

        ImageButton editButton = (ImageButton)findViewById(R.id.edit_weather_button);
        editButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickEditButton();
            }
        });

        mRefreshButton = (ImageButton)findViewById(R.id.refresh_button);
        mImage = (ImageView)findViewById(R.id.weather_image);
        mTemperatureTextView = (TextView)findViewById(R.id.temperature_text_view);
        mWindTextView = (TextView)findViewById(R.id.wind_text_view);
        mSkyTextView= (TextView)findViewById(R.id.sky_text_view);

        // update views with some default data
        Weather defaultData = new Weather(0, 0, "Cloudy");
        updateViews(defaultData);
    }

    public void updateViews(Weather weather) {
        String mph = getResources().getString(R.string.mph);
        String wind = getResources().getString(R.string.wind_speed) + ": " + weather.getWindSpeedAsString() + " " + mph;
        String sky = getResources().getString(R.string.sky_conditions) + ": " + weather.getSkyConditions();
        String degrees = weather.getTemperatureAsString() + getResources().getString(R.string.degrees_f);

        mTemperatureTextView.setText(degrees);
        mWindTextView.setText(wind);
        mSkyTextView.setText(sky);

        if (weather.getImageUrl() != null)
            Picasso.with(getContext()).load(weather.getImageUrl()).into(mImage);
        else
            mImage.setVisibility(View.GONE);
    }

    private void onClickEditButton() {

    }

    public void setOnClickRefreshButton(OnClickListener onClickListener) {
        mRefreshButton.setOnClickListener(onClickListener);
    }
}
