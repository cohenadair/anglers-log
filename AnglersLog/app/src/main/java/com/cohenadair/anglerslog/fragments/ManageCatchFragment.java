package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;

/**
 * The ManageCatchFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends Fragment {

    private TextView mSpeciesTextView;

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_catch, container, false);

        mSpeciesTextView = (TextView)view.findViewById(R.id.species_text_view);
        mSpeciesTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(FragmentData.PRIMITIVE_SPECIES);
                fragment.setOnDismissInterface(new ManagePrimitiveFragment.OnDismissInterface() {
                    @Override
                    public void onDismiss(UserDefineObject selectedItem) {
                        mSpeciesTextView.setText(selectedItem.getName());
                    }
                });

                fragment.show(getFragmentManager(), "dialog");
            }
        });

        return view;
    }

}
