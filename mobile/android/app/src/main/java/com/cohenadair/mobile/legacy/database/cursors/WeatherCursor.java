package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;
import android.database.CursorWrapper;

import com.cohenadair.mobile.legacy.Weather;
import com.cohenadair.mobile.legacy.database.LogbookSchema.WeatherTable;

/**
 * A {@link Cursor} wrapper for the {@link Weather} object.
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
