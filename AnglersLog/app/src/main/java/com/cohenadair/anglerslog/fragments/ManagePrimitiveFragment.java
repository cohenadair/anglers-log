package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.fragment.FragmentUtils;
import com.cohenadair.anglerslog.utilities.fragment.PrimitiveFragmentInfo;

import java.util.List;

/**
 * The ManagePrimitiveFragment is used for selecting user defines from a list when adding Catches or
 * Trips.
 */
public class ManagePrimitiveFragment extends DialogFragment {

    private RecyclerView mContentRecyclerView;
    private EditText mNewItemEdit;
    private Button mAddButton;
    private Toolbar mToolbar;
    private OnDismissInterface mOnDismissInterface;
    private PrimitiveFragmentInfo mPrimitiveInfo;

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
        mPrimitiveInfo = FragmentUtils.primitiveInfo(getActivity(), primitiveId);

        if (mPrimitiveInfo != null) {
            initViews(view);
            getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        }

        return view;
    }

    private void initViews(View view) {
        mContentRecyclerView = (RecyclerView)view.findViewById(R.id.content_recycler_view);
        mContentRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        mContentRecyclerView.setAdapter(new ManagePrimitiveAdapter(mPrimitiveInfo.getItems()));

        mNewItemEdit = (EditText)view.findViewById(R.id.new_item_edit);
        mNewItemEdit.setHint(getResources().getString(R.string.hint_new_item) + " " + mPrimitiveInfo.getName());

        mAddButton = (Button)view.findViewById(R.id.add_button);
        mAddButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = mNewItemEdit.getText().toString();

                if (!name.equals(""))
                    if (mPrimitiveInfo.getInterface().onAddItem(name))
                        mContentRecyclerView.getAdapter().notifyDataSetChanged();

                mNewItemEdit.setText("");
            }
        });

        mToolbar = (Toolbar)view.findViewById(R.id.toolbar);
        mToolbar.inflateMenu(R.menu.menu_manage_primitive);
        mToolbar.setOnMenuItemClickListener(new Toolbar.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                Log.d("OnMenuClick", item.toString());
                return false;
            }
        });
    }

    //region List View Item ViewHolder
    private class ManagePrimitiveHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private EditText mNameEditText;
        private TextView mNameTextView;
        private CheckBox mDeleteCheckBox;

        public ManagePrimitiveHolder(View view) {
            super(view);
            view.setOnClickListener(this);

            mNameEditText = (EditText)view.findViewById(R.id.name_edit_text);
            mNameTextView = (TextView)view.findViewById(R.id.name_text_view);
            mDeleteCheckBox = (CheckBox)view.findViewById(R.id.delete_check_box);
        }

        @Override
        public void onClick(View view) {
            mOnDismissInterface.onDismiss(mPrimitiveInfo.getInterface().onClickItem(getLayoutPosition()));
            getDialog().dismiss();
        }

        //region Getters & Setters
        public EditText getNameEditText() {
            return mNameEditText;
        }

        public void setNameEditText(EditText nameEditText) {
            mNameEditText = nameEditText;
        }

        public TextView getNameTextView() {
            return mNameTextView;
        }

        public void setNameTextView(TextView nameTextView) {
            mNameTextView = nameTextView;
        }

        public CheckBox getDeleteCheckBox() {
            return mDeleteCheckBox;
        }

        public void setDeleteCheckBox(CheckBox deleteCheckBox) {
            mDeleteCheckBox = deleteCheckBox;
        }
        //endregion
    }
    //endregion

    //region RecyclerView Adapter
    private class ManagePrimitiveAdapter extends RecyclerView.Adapter<ManagePrimitiveHolder> {

        private List<UserDefineObject> mItems;

        public ManagePrimitiveAdapter(List<UserDefineObject> items) {
            mItems = items;
        }

        @Override
        public ManagePrimitiveHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getActivity());
            View view = inflater.inflate(R.layout.list_item_manage_primitive, parent, false);
            return new ManagePrimitiveHolder(view);
        }

        @Override
        public void onBindViewHolder(ManagePrimitiveHolder holder, int position) {
            UserDefineObject obj = mItems.get(position);
            holder.getNameEditText().setText(obj.getName());
            holder.getNameTextView().setText(obj.getName());
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

    }
    //endregion

}
