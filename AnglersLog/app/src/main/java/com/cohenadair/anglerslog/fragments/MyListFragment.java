package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.utilities.fragment.FragmentInfo;

/**
 * The fragment showing the list of catches.
 */
public class MyListFragment extends Fragment {

    private ListView mListView;
    private FloatingActionButton mNewButton;

    //region Callback Interface
    OnMyListFragmentInteractionListener mCallbacks;

    // callback interface for the fragment's activity
    public interface OnMyListFragmentInteractionListener {
        void onItemSelected(int position);
        void onClickNewButton(View v);
    }
    //endregion
    
    // used to keep fragment state through attach/detach
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
            initListView(view, info);
        }

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (OnMyListFragmentInteractionListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement OnMyListFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    //region View Initializing
    private void initListView(View view, FragmentInfo fragmentInfo) {
        mListView = (ListView)view.findViewById(R.id.main_list_view);

        // on click item
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                mCallbacks.onItemSelected(position);
            }
        });

        // adapter
        if (fragmentInfo != null)
            mListView.setAdapter(fragmentInfo.getArrayAdapter());
    }

    private void initNewButton(View view) {
        mNewButton = (FloatingActionButton)view.findViewById(R.id.new_button);

        // on click
        mNewButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onClickNewButton(v);
            }
        });
    }
    //endregion
}
