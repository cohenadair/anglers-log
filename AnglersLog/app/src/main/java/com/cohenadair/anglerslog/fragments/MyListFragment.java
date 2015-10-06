package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;

/**
 * The fragment showing the list of catches.
 */
public class MyListFragment extends Fragment {

    //region Callback Interface
    InteractionListener mCallbacks;

    /**
     * Callback interface must be implemented by any Activity implementing MyListFragment.
     */
    public interface InteractionListener {
        void onMyListClickNewButton();
    }
    //endregion

    /**
     * Used to keep fragment state through attach/detach.
     */
    private static final String ARG_FRAGMENT_ID = "arg_fragment_id";

    /**
     * Creates a new instance with a fragment id used to show different array data.
     * @param aFragmentId the fragment id.
     * @return a MyListFragment instance with associated data id.
     */
    public static MyListFragment newInstance(int aFragmentId) {
        MyListFragment fragment = new MyListFragment();
        
        // add data id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putInt(MyListFragment.ARG_FRAGMENT_ID, aFragmentId);
        
        fragment.setArguments(args);
        return fragment;
    }

    public MyListFragment() {
        // default constructor required
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_mylist, container, false);

        int fragmentId = getArguments().getInt(ARG_FRAGMENT_ID);
        FragmentInfo info = FragmentData.fragmentInfo(getActivity(), fragmentId);

        if (view != null) {
            initNewButton(view);
            initRecyclerView(view, info);
        }

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (InteractionListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement MyListFragment.InteractionListener.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    //region View Initializing
    private void initRecyclerView(View view, FragmentInfo fragmentInfo) {
        RecyclerView recyclerView = (RecyclerView)view.findViewById(R.id.main_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));

        if (fragmentInfo != null)
            recyclerView.setAdapter(fragmentInfo.getArrayAdapter());
    }

    private void initNewButton(View view) {
        FloatingActionButton newButton = (FloatingActionButton)view.findViewById(R.id.new_button);
        newButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onMyListClickNewButton();
            }
        });
    }
    //endregion
}