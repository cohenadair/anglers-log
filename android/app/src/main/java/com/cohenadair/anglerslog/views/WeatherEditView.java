package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Spinner;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;

/**
 * A EditWeatherView is a view that used for adding, updating, or removing a {@link Weather} object.
 * @author Cohen Adair
 */
public class WeatherEditView extends LinearLayout {

    private InputTextView mTemperatureView;
    private InputTextView mWindSpeedView;
    private InputTextView mSkyConditionsView;
    private InteractionListener mCallbacks;

    public interface InteractionListener {
        void onClickRefreshButton();
    }

    public WeatherEditView(Context context) {
        this(context, null);
        init();
    }

    public WeatherEditView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.view_weather_edit, this);

        mTemperatureView = (InputTextView)findViewById(R.id.temperature_view);
        mTemperatureView.setAllowsNegativeNumbers(true);

        mWindSpeedView = (InputTextView)findViewById(R.id.wind_speed_view);
        mSkyConditionsView = (InputTextView)findViewById(R.id.sky_conditions_view);

        initUnitsSpinner();
        initRefreshButton();
    }

    public Weather getWeather() {
        String temp = mTemperatureView.getInputText();
        String wind = mWindSpeedView.getInputText();
        String sky = mSkyConditionsView.getInputText();

        if (temp == null || wind == null || sky == null) {
            AlertUtils.showError(getContext(), R.string.error_weather_form);
            return null;
        }

        return new Weather(
                Integer.parseInt(mTemperatureView.getInputText()),
                Integer.parseInt(mWindSpeedView.getInputText()),
                mSkyConditionsView.getInputText()
        );
    }

    public void setWeather(Weather weather) {
        if (weather == null)
            return;

        mTemperatureView.setInputText(weather.getTemperatureAsString());
        mWindSpeedView.setInputText(weather.getWindSpeedAsString());
        mSkyConditionsView.setInputText(weather.getSkyConditions());
    }

    public void setCallbacks(InteractionListener callbacks) {
        mCallbacks = callbacks;
    }

    public void reset() {
        mTemperatureView.setInputText("");
        mWindSpeedView.setInputText("");
        mSkyConditionsView.setInputText("");
    }

    private void initUnitsSpinner() {
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getContext(), R.array.pref_unitTypes_entries, R.layout.list_item_spinner);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        Spinner spinner = (Spinner)findViewById(R.id.units_spinner);
        spinner.setAdapter(adapter);

        int weatherUnits = LogbookPreferences.getWeatherUnits();
        spinner.setSelection((weatherUnits == -1) ? LogbookPreferences.getUnits() : weatherUnits);

        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                LogbookPreferences.setWeatherUnits(position);
                mTemperatureView.setTitle(getTemperatureLabel(position == Logbook.UNIT_IMPERIAL));
                mWindSpeedView.setTitle(getWindLabel(position == Logbook.UNIT_IMPERIAL));
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

    private void initRefreshButton() {
        ImageButton refresh = (ImageButton)findViewById(R.id.refresh_button);
        refresh.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCallbacks != null)
                    mCallbacks.onClickRefreshButton();
            }
        });
    }
}
