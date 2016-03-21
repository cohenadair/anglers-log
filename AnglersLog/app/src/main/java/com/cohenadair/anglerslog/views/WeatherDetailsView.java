package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;

/**
 * A WeatherDetailsView is a view that displays weather data.
 * Created by Cohen Adair on 2016-01-13.
 */
public class WeatherDetailsView extends LinearLayout {

    private TextView mTemperatureTextView;
    private TextView mWindTextView;
    private TextView mSkyTextView;

    public WeatherDetailsView(Context context) {
        this(context, null);
        init(null);
    }

    public WeatherDetailsView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_weather_details, this);

        mTemperatureTextView = (TextView)findViewById(R.id.temperature_text_view);
        mWindTextView = (TextView)findViewById(R.id.wind_text_view);
        mSkyTextView= (TextView)findViewById(R.id.sky_text_view);
    }

    public void updateViews(Weather weather) {
        if (weather == null)
            return;

        boolean isImperial = LogbookPreferences.getWeatherUnits() == Logbook.UNIT_IMPERIAL;

        String ph = isImperial ? getResources().getString(R.string.mph) : getResources().getString(R.string.kmh);
        String deg = isImperial ? getResources().getString(R.string.degrees_f) : getResources().getString(R.string.degrees_c);
        String wind = getResources().getString(R.string.wind_speed) + ": " + weather.getWindSpeedAsString() + " " + ph;
        String sky = getResources().getString(R.string.sky_conditions) + ": " + (weather.getSkyConditions() != null ? weather.getSkyConditions() : getResources().getString(R.string.unknown));
        String degrees = weather.getTemperatureAsString() + deg;

        mTemperatureTextView.setText(degrees);
        mWindTextView.setText(wind);
        mSkyTextView.setText(sky);
    }
}
