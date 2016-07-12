package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;
import android.database.CursorWrapper;

import com.cohenadair.anglerslog.model.Weather;

import static com.cohenadair.anglerslog.database.LogbookSchema.WeatherTable;

/**
 * A {@link Cursor} wrapper for the {@link com.cohenadair.anglerslog.model.Weather} object.
 * @author Cohen Adair
 */
public class WeatherCursor extends CursorWrapper {

    public WeatherCursor(Cursor cursor) {
        super(cursor);
    }

    public Weather getWeather() {
        return new Weather(
                getInt(getColumnIndex(WeatherTable.Columns.TEMPERATURE)),
                getInt(getColumnIndex(WeatherTable.Columns.WIND_SPEED)),
                getString(getColumnIndex(WeatherTable.Columns.SKY_CONDITIONS))
        );
    }

}
