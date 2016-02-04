package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * A EditWeatherView is a view that used for editing or adding weather data.
 * Created by Cohen Adair on 2016-01-13.
 */
public class WeatherEditView extends LinearLayout {

    private EditText mTemperatureEditText;
    private EditText mWindEditText;
    private EditText mSkyEditText;

    public WeatherEditView(Context context) {
        this(context, null);
        init(null);
    }

    public WeatherEditView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_weather_edit, this);

        mTemperatureEditText = (EditText)findViewById(R.id.temp_edit_text);
        mWindEditText = (EditText)findViewById(R.id.wind_edit_text);
        mSkyEditText = (EditText)findViewById(R.id.sky_edit_text);

        initUnitsSpinner();
    }

    public Weather getWeather() {
        String temp = mTemperatureEditText.getText().toString();
        String wind = mWindEditText.getText().toString();
        String sky = mSkyEditText.getText().toString();

        if (temp.equals("") || wind.equals("") || sky.equals("")) {
            Utils.showErrorAlert(getContext(), R.string.error_weather_form);
            return null;
        }

        return new Weather(
                Integer.parseInt(mTemperatureEditText.getText().toString()),
                Integer.parseInt(mWindEditText.getText().toString()),
                mSkyEditText.getText().toString()
        );
    }

    public void setWeather(Weather weather) {
        if (weather == null)
            return;

        mTemperatureEditText.setText(weather.getTemperatureAsString());
        mWindEditText.setText(weather.getWindSpeedAsString());
        mSkyEditText.setText(weather.getSkyConditions());
    }

    public void reset() {
        mTemperatureEditText.setText("");
        mWindEditText.setText("");
        mSkyEditText.setText("");
    }

    private void initUnitsSpinner() {
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getContext(), R.array.pref_unitTypes_entries, R.layout.list_item_spinner_medium);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        Spinner spinner = (Spinner)findViewById(R.id.units_spinner);
        spinner.setAdapter(adapter);

        int weatherUnits = LogbookPreferences.getWeatherUnits();
        spinner.setSelection((weatherUnits == -1) ? LogbookPreferences.getUnits() : weatherUnits);

        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                LogbookPreferences.setWeatherUnits(position);

                TextView temperature = (TextView) findViewById(R.id.temperature_label);
                TextView windSpeed = (TextView) findViewById(R.id.wind_label);
                temperature.setText(getTemperatureLabel(position == Logbook.UNIT_IMPERIAL));
                windSpeed.setText(getWindLabel(position == Logbook.UNIT_IMPERIAL));
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private String getTemperatureLabel(boolean isImperial) {
        return getResources().getString(R.string.temperature) + " (" + Logbook.getTemperatureUnits(isImperial) + ")";
    }

    private String getWindLabel(boolean isImperial) {
        return getResources().getString(R.string.wind_speed) + " (" + Logbook.getSpeedUnits(isImperial) + ")";
    }
}
