package com.cohenadair.anglerslog.views;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Weather;

/**
 * A WeatherView is a view that used for getting, displaying, and managing weather data.
 * Created by Cohen Adair on 2016-01-13.
 */
public class WeatherView extends LinearLayout {

    private ImageButton mDeleteButton;
    private ImageButton mEditButton;
    private WeatherDetailsView mDetailsView;

    private InteractionListener mListener;

    public interface InteractionListener {
        void onClickRemoveButton();
        void onClickEditButton();
        void onClickRefreshButton();
    }

    public WeatherView(Context context) {
        this(context, null);
        init(null);
    }

    public WeatherView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_weather, this);

        mDeleteButton = (ImageButton)findViewById(R.id.delete_weather_button);
        mDeleteButton.setVisibility(View.GONE);
        mDeleteButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mListener.onClickRemoveButton();
                reset();
            }
        });

        mEditButton = (ImageButton)findViewById(R.id.edit_weather_button);
        mEditButton.setImageResource(R.drawable.ic_add);
        mEditButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mListener.onClickEditButton();
            }
        });

        ImageButton refreshButton = (ImageButton)findViewById(R.id.refresh_button);
        refreshButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mListener.onClickRefreshButton();
            }
        });

        // hide details by default
        mDetailsView = (WeatherDetailsView)findViewById(R.id.details_view);
        mDetailsView.setVisibility(View.GONE);
    }

    public void updateViews(Weather weather) {
        if (weather == null) {
            reset();
            return;
        }

        mDetailsView.updateViews(weather);
        mDetailsView.setVisibility(View.VISIBLE);
        mDeleteButton.setVisibility(View.VISIBLE);
        mEditButton.setImageResource(R.drawable.ic_edit);
    }

    private void reset() {
        mDetailsView.setVisibility(View.GONE);
        mDeleteButton.setVisibility(View.GONE);
        mEditButton.setImageResource(R.drawable.ic_add);
    }

    public void setListener(InteractionListener listener) {
        mListener = listener;
    }

    //region Weather Edit Dialog

    /**
     * Used to edit or add weather data. It extends DialogFragment so it's state survives rotation.
     * By default, AlertDialogs close when its Activity is closed, but when wrapped in a Fragment
     * it will remain open.
     */
    public static class EditDialog extends DialogFragment {

        private static final String ARG_TEMP = "temperature";
        private static final String ARG_WIND = "wind";
        private static final String ARG_SKY = "sky";

        private InteractionListener mInteractionListener;

        public interface InteractionListener {
            void onSave(Weather weather);
        }

        public static EditDialog newInstance(Weather weather) {
            EditDialog dialog = new EditDialog();

            // add primitive id to bundle so save through orientation changes
            Bundle args = new Bundle();

            if (weather != null) {
                args.putInt(ARG_TEMP, weather.getTemperature());
                args.putInt(ARG_WIND, weather.getWindSpeed());
                args.putString(ARG_SKY, weather.getSkyConditions());
            }

            dialog.setArguments(args);
            return dialog;
        }

        public void setInteractionListener(InteractionListener interactionListener) {
            mInteractionListener = interactionListener;
        }

        @NonNull
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            LayoutInflater inflater = getActivity().getLayoutInflater();

            // inflate the wrapper view and retrieve the EditWeatherView
            final View dialogView = inflater.inflate(R.layout.view_weather_edit_wrapper, null); // null is okay here because it's a dialog
            final WeatherEditView editView = (WeatherEditView)dialogView.findViewById(R.id.edit_weather_view);

            // set weather properties if needed
            String sky = getArguments().getString(ARG_SKY, null);
            if (sky != null)
                editView.setWeather(new Weather(getArguments().getInt(ARG_TEMP), getArguments().getInt(ARG_WIND), getArguments().getString(ARG_SKY)));

            AlertDialog.Builder dialog = new AlertDialog.Builder(getActivity());
            dialog.setView(dialogView);
            dialog.setPositiveButton(R.string.button_save, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    mInteractionListener.onSave(editView.getWeather());
                    editView.reset();
                    getDialog().dismiss();
                }
            });
            dialog.setNegativeButton(R.string.button_cancel, null);

            return dialog.create();
        }
    }
    //endregion
}
