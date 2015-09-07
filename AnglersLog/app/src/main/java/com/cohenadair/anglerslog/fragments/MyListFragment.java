package com.cohenadair.anglerslog.fragments;

import android.app.Activity;
import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ListView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.FragmentInfo;
import com.cohenadair.anglerslog.utilities.FragmentUtils;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * The fragment showing the list of catches.
 */
public class MyListFragment extends Fragment {

    private ListView mListView;
    private FloatingActionButton mNewButton;

    //region Callback Interface
    OnListItemSelectedListener mCallbacks;

    // callback interface for the fragment's activity
    public interface OnListItemSelectedListener {
        void onItemSelected(int pos);
    }
    //endregion
    
    // used to keep fragment state through attach/detach
    private static final String ARG_FRAGMENT_ID = "arg_fragment_id";

    /**
     * Creates a new instance with a data id used to show different array data.
     * @param aFragmentId the Logbook.DATA_* id for the new instance
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

        // set the list's adapter
        int dataId = getArguments().getInt(ARG_FRAGMENT_ID);
        FragmentInfo info = FragmentUtils.fragmentInfo(getActivity(), dataId);

        if (view != null) {
            initNewButton(view);
            initListView(view, info);
        }

        return view;
    }

    // required until issue resolved
    // https://code.google.com/p/android/issues/detail?id=183358
    // TODO update to onAttach(Context context)
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (OnListItemSelectedListener)activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnListItemSelectedListener");
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

        // on scroll
        mListView.setOnScrollListener(new AbsListView.OnScrollListener() {
            // used for proper hiding/showing for a list that isn't "scrollable"
            private boolean mDidScroll = false;

            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                if (scrollState == AbsListView.OnScrollListener.SCROLL_STATE_IDLE)
                    mNewButton.show();
                else if (mDidScroll) {
                    mNewButton.hide();
                    mDidScroll = false;
                }
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                mDidScroll = true;
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
                Utils.showToast(getActivity(), "New list item!");
            }
        });
    }
    //endregion
}
