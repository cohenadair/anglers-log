package com.cohenadair.anglerslog.fragments;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import com.cohenadair.anglerslog.model.Logbook;

/**
 * The fragment showing the list of catches.
 */
public class MyListFragment extends android.app.ListFragment {

    //region Callback Interface
    OnListItemSelectedListener mCallbacks;

    // callback interface for the fragment's activity
    public interface OnListItemSelectedListener {
        void onItemSelected(int pos);
    }
    //endregion
    
    // used to keep fragment state through attach/detach
    private static final String ARG_LOGBOOK_DATA = "arg_logbook_data";

    /**
     * Creates a new instance with a data id used to show different array data.
     * @param logbookDataId the Logbook.DATA_* id for the new instance
     * @return a MyListFragment instance with associated data id.
     */
    public static MyListFragment newInstance(int logbookDataId) {
        MyListFragment fragment = new MyListFragment();
        
        // add data id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putInt(MyListFragment.ARG_LOGBOOK_DATA, logbookDataId);
        
        fragment.setArguments(args);
        return fragment;
    }

    public MyListFragment() {
        // default constructor required
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View aView = super.onCreateView(inflater, container, savedInstanceState);

        // set the list's adapter
        int dataId = getArguments().getInt(ARG_LOGBOOK_DATA);
        this.setListAdapter(Logbook.getInstance().adapterForData(getActivity(), dataId));

        return aView;
    }

    @Override
    public void onListItemClick(ListView listView, View view, int pos, long id) {
        mCallbacks.onItemSelected(pos);
    }

    @Override
    public void onAttach(Activity anActivity) {
        super.onAttach(anActivity);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (OnListItemSelectedListener)anActivity;
        } catch (ClassCastException e) {
            throw new ClassCastException(anActivity.toString() + " must implement OnListItemSelectedListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }
}
