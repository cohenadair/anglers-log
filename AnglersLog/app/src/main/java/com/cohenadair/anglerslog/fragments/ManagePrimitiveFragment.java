package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.fragment.FragmentUtils;
import com.cohenadair.anglerslog.utilities.fragment.PrimitiveFragmentInfo;

/**
 * The ManagePrimitiveFragment is used for selecting user defines from a list when adding Catches or
 * Trips.
 */
public class ManagePrimitiveFragment extends DialogFragment {

    private ListView mContentListView;
    private EditText mNewItemEdit;
    private Button mAddButton;
    private OnDismissInterface mOnDismissInterface;

    public interface OnDismissInterface {
        void onDismiss(UserDefineObject selectedItem);
    }

    // used to keep fragment state through attach/detach
    private static final String ARG_PRIMITIVE_ID = "arg_primitive_id";

    public static ManagePrimitiveFragment newInstance(int primitiveId) {
        ManagePrimitiveFragment fragment = new ManagePrimitiveFragment();

        // add primitive id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putInt(ManagePrimitiveFragment.ARG_PRIMITIVE_ID, primitiveId);

        fragment.setArguments(args);
        return fragment;
    }

    public ManagePrimitiveFragment() {
        // Required empty public constructor
    }

    //region Getters & Setters
    public OnDismissInterface getOnDismissInterface() {
        return mOnDismissInterface;
    }

    public void setOnDismissInterface(OnDismissInterface onDismissInterface) {
        mOnDismissInterface = onDismissInterface;
    }
    //endregion

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_primitive, container, false);

        int primitiveId = getArguments().getInt(ARG_PRIMITIVE_ID);
        PrimitiveFragmentInfo info = FragmentUtils.primitiveInfo(getActivity(), primitiveId);

        if (info != null) {
            initViews(view, info);
            getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        }

        return view;
    }

    private void initViews(View view, final PrimitiveFragmentInfo info) {
        mContentListView = (ListView)view.findViewById(R.id.content_list_view);
        mContentListView.setAdapter(info.getArrayAdapter());
        mContentListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                mOnDismissInterface.onDismiss(info.getInterface().onClickItem(position));
                getDialog().dismiss();
            }
        });

        mNewItemEdit = (EditText)view.findViewById(R.id.new_item_edit);
        mNewItemEdit.setHint(getResources().getString(R.string.hint_new_item) + " " + info.getName());

        mAddButton = (Button)view.findViewById(R.id.add_button);
        mAddButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = mNewItemEdit.getText().toString();

                if (!name.equals(""))
                    info.getInterface().onAddItem(name);

                mNewItemEdit.setText("");
            }
        });
    }

}
