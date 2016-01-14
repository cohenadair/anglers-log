package com.cohenadair.anglerslog.catches;

import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.location.Location;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.DatePicker;
import android.widget.TimePicker;

import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;
import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DatePickerFragment;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.fragments.TimePickerFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.user_defines.WaterClarity;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectionSpinnerView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;
import com.cohenadair.anglerslog.views.WeatherView;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.model.LatLng;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.UUID;

/**
 * The ManageBaitFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends ManageContentFragment {

    private TitleSubTitleView mDateView;
    private TitleSubTitleView mTimeView;
    private TitleSubTitleView mSpeciesView;
    private TitleSubTitleView mLocationView;
    private TitleSubTitleView mBaitView;
    private TitleSubTitleView mWaterClarityView;
    private TitleSubTitleView mFishingMethodsView;
    private SelectionSpinnerView mResultSpinner;
    private WeatherView mWeatherView;

    private RequestQueue mRequestQueue;
    private GoogleApiClient mGoogleApiClient;

    /**
     * Used so there is no database interaction until the user saves their changes.
     */
    private ArrayList<UserDefineObject> mSelectedFishingMethods;

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    private Catch getNewCatch() {
        return (Catch)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_catch, container, false);

        initGoogleApi();
        initDateTimeView(view);
        initSpeciesView(view);
        initLocationView(view);
        initBaitView(view);
        initSelectPhotosView(view);
        initWaterClarityView(view);
        initFishingMethodsView(view);
        initResultView(view);
        initWeatherView(view);

        initSubclassObject();

        // reset for each time the view is created
        if (!isEditing())
            mSelectedFishingMethods = new ArrayList<>();

        mRequestQueue = Volley.newRequestQueue(getContext());

        return view;
    }

    @Override
    public void onStart() {
        mGoogleApiClient.connect();
        super.onStart();
    }

    @Override
    public void onStop() {
        mGoogleApiClient.disconnect();
        super.onStop();
    }

    @Override
    public void onResume() {
        super.onResume();
        Utils.requestLocationServices(getContext());
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_catch, R.string.success_catch, R.string.error_catch_edit, R.string.success_catch_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editCatch(getEditingId(), getNewCatch());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addCatch(getNewCatch());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getCatch(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                Catch newCatch = new Catch((Catch) oldObject, true);
                mSelectedFishingMethods = newCatch.getFishingMethods();
                return newCatch;
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Catch(new Date());
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        // species
        if (getNewCatch().getSpecies() == null) {
            Utils.showErrorAlert(getActivity(), R.string.error_catch_species);
            return false;
        }

        // update fishing methods
        getNewCatch().setFishingMethods(mSelectedFishingMethods);

        return true;
    }

    @Override
    public void updateViews() {
        mDateView.setSubtitle(getNewCatch().getDateAsString());
        mTimeView.setSubtitle(getNewCatch().getTimeAsString());
        mSpeciesView.setSubtitle(getNewCatch().getSpeciesAsString());
        mBaitView.setSubtitle(getNewCatch().getBaitAsString());
        mLocationView.setSubtitle(getNewCatch().getFishingSpotAsString());
        mWaterClarityView.setSubtitle(getNewCatch().getWaterClarityAsString());
        mFishingMethodsView.setSubtitle(UserDefineArrays.namesAsString(mSelectedFishingMethods));
        mResultSpinner.setSelection(getNewCatch().getCatchResult().getValue());
    }

    //region Google API
    private void initGoogleApi() {
        if (mGoogleApiClient != null)
            return;

        mGoogleApiClient = new GoogleApiClient.Builder(getContext())
                .addConnectionCallbacks(new GoogleApiClient.ConnectionCallbacks() {
                    @Override
                    public void onConnected(Bundle bundle) {
                        if (!isEditing())
                            requestWeatherData();
                    }

                    @Override
                    public void onConnectionSuspended(int i) {

                    }
                })
                .addApi(LocationServices.API)
                .build();
    }
    //endregion

    //region Date & Time
    private void initDateTimeView(View view) {
        mDateView = (TitleSubTitleView)view.findViewById(R.id.date_layout);
        mDateView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DatePickerFragment datePicker = new DatePickerFragment();
                datePicker.setOnDateSetListener(new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        updateCalendar();
                        Calendar c = Calendar.getInstance();
                        int hours = c.get(Calendar.HOUR_OF_DAY);
                        int minutes = c.get(Calendar.MINUTE);
                        c.set(year, monthOfYear, dayOfMonth, hours, minutes);
                        updateDateView(c.getTime());
                    }
                });
                datePicker.show(getFragmentManager(), "datePicker");
            }
        });

        mTimeView = (TitleSubTitleView)view.findViewById(R.id.time_layout);
        mTimeView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TimePickerFragment timePicker = new TimePickerFragment();
                timePicker.setOnTimeSetListener(new TimePickerDialog.OnTimeSetListener() {
                    @Override
                    public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
                        updateCalendar();
                        Calendar c = Calendar.getInstance();
                        int year = c.get(Calendar.YEAR);
                        int month = c.get(Calendar.MONTH);
                        int day = c.get(Calendar.DAY_OF_MONTH);
                        c.set(year, month, day, hourOfDay, minute);
                        updateTimeView(c.getTime());
                    }
                });
                timePicker.show(getFragmentManager(), "timePicker");
            }
        });
    }

    /**
     * Updates the date view's text.
     * @param date The date to display in the view. Only looks at the date portion.
     */
    private void updateDateView(Date date) {
        getNewCatch().setDate(date);
        mDateView.setSubtitle(getNewCatch().getDateAsString());
    }

    /**
     * Updates the time view's text.
     * @param date The date to display in the view. Only looks at the time portion.
     */
    private void updateTimeView(Date date) {
        getNewCatch().setDate(date);
        mTimeView.setSubtitle(getNewCatch().getTimeAsString());
    }

    /**
     * Resets the calendar's time to the current catch's time.
     */
    private void updateCalendar() {
        Calendar.getInstance().setTime(getNewCatch().getDate());
    }
    //endregion

    private void initSpeciesView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UserDefineObject> selectedItems) {
                getNewCatch().setSpecies((Species)selectedItems.get(0));
                mSpeciesView.setSubtitle(getNewCatch().getSpeciesAsString());
            }
        };

        mSpeciesView = (TitleSubTitleView)view.findViewById(R.id.species_layout);
        mSpeciesView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.SPECIES, false, onDismissInterface);
            }
        });
    }

    private void initLocationView(View view) {
        mLocationView = (TitleSubTitleView)view.findViewById(R.id.location_layout);
        mLocationView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_LOCATIONS, new OnSelectionActivityResult() {
                    @Override
                    public void onSelect(UUID id) {
                        getNewCatch().setFishingSpot(Logbook.getFishingSpot(id));
                    }
                });
            }
        });
    }

    private void initBaitView(View view) {
        mBaitView = (TitleSubTitleView)view.findViewById(R.id.bait_layout);
        mBaitView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_BAITS, new OnSelectionActivityResult() {
                    @Override
                    public void onSelect(UUID id) {
                        getNewCatch().setBait(Logbook.getBait(id));
                    }
                });
            }
        });
    }

    private void initWaterClarityView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UserDefineObject> selectedItems) {
                getNewCatch().setWaterClarity((WaterClarity)selectedItems.get(0));
                mWaterClarityView.setSubtitle(getNewCatch().getWaterClarityAsString());
            }
        };

        mWaterClarityView = (TitleSubTitleView)view.findViewById(R.id.clarity_layout);
        mWaterClarityView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.WATER_CLARITY, false, onDismissInterface);
            }
        });
    }

    private void initFishingMethodsView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UserDefineObject> selectedItems) {
                mSelectedFishingMethods = selectedItems;
                mFishingMethodsView.setSubtitle(UserDefineArrays.namesAsString(mSelectedFishingMethods));
            }
        };

        mFishingMethodsView = (TitleSubTitleView)view.findViewById(R.id.methods_layout);
        mFishingMethodsView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.FISHING_METHODS, true, onDismissInterface);
            }
        });
    }

    private void initResultView(View view) {
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getContext(), R.array.result_types, R.layout.list_item_spinner);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mResultSpinner = (SelectionSpinnerView)view.findViewById(R.id.result_spinner);
        mResultSpinner.setAdapter(adapter);
        mResultSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                getNewCatch().setCatchResult(Catch.CatchResult.fromInt(position));
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    //region Weather View
    private void initWeatherView(View view) {
        mWeatherView = (WeatherView)view.findViewById(R.id.weather_view);
        mWeatherView.setListener(new WeatherView.InteractionListener() {
            @Override
            public void onClickRemoveButton() {
                getNewCatch().setWeather(null);
            }

            @Override
            public void onClickEditButton() {
                WeatherView.EditDialog editDialog = WeatherView.EditDialog.newInstance(getNewCatch().getWeather());

                editDialog.setInteractionListener(new WeatherView.EditDialog.InteractionListener() {
                    @Override
                    public void onSave(Weather weather) {
                        mWeatherView.updateViews(weather);
                    }
                });

                editDialog.show(getChildFragmentManager(), "EditWeatherDialog");
            }

            @Override
            public void onClickRefreshButton() {
                requestWeatherData();
            }
        });
    }

    private void updateWeatherView(Weather weather) {
        mWeatherView.updateViews(weather);
        getNewCatch().setWeather(weather);
    }

    private void requestWeatherData() {
        if (!mGoogleApiClient.isConnected()) {
            Utils.showToast(getContext(), R.string.error_google_services);
            return;
        }

        Location loc = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
        if (loc == null) {
            Utils.showToast(getContext(), R.string.error_user_location);
            return;
        }

        final Weather weather = new Weather(new LatLng(loc.getLatitude(), loc.getLongitude()));
        mRequestQueue.add(weather.getRequest(new Weather.OnFetchInterface() {
            @Override
            public void onSuccess() {
                updateWeatherView(weather);
            }

            @Override
            public void onError() {
                Utils.showToast(getContext(), R.string.error_getting_weather);
            }
        }));
    }
    //endregion

    private void showPrimitiveDialog(int primitiveId, boolean multiple, ManagePrimitiveFragment.OnDismissInterface onDismissInterface) {
        ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(primitiveId, multiple);

        if (multiple)
            fragment.setSelectedObjects(mSelectedFishingMethods);

        fragment.setOnDismissInterface(onDismissInterface);
        fragment.show(getChildFragmentManager(), "PrimitiveDialog");
    }
}
