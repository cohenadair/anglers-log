package com.cohenadair.anglerslog.trips;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

/**
 * The ManageTripFragment is used to add and edit trips.
 * Created by Cohen Adair on 2016-01-20.
 */
public class ManageTripFragment extends ManageContentFragment {

    public ManageTripFragment() {
        // Required empty public constructor
    }

    private Trip getNewTrip() {
        return (Trip)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_trip, container, false);

        return view;
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_trip, R.string.success_trip, R.string.error_trip_edit, R.string.success_trip_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editTrip(getEditingId(), getNewTrip());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addTrip(getNewTrip());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getTrip(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                return new Trip((Trip)oldObject, true);
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Trip();
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        return true;
    }

    @Override
    public void updateViews() {
    }

}
