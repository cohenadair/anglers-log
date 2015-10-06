package com.cohenadair.anglerslog.fragments;

import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.WrappedLinearLayoutManager;
import com.cohenadair.anglerslog.utilities.fragment.FragmentData;
import com.cohenadair.anglerslog.utilities.fragment.PrimitiveFragmentInfo;

import java.util.List;

/**
 * The ManagePrimitiveFragment is used for selecting user defines from a list when adding Catches or
 * Trips.
 */
public class ManagePrimitiveFragment extends DialogFragment {

    private RecyclerView mContentRecyclerView;
    private EditText mNewItemEdit;
    private Toolbar mToolbar;
    private OnDismissInterface mOnDismissInterface;
    private PrimitiveFragmentInfo mPrimitiveInfo;

    /**
     * Different "management" types for this fragment. Used to display different list item layotus.
     */
    private enum ManageType {
        Selection,
        Edit,
        Delete
    }

    /**
     * OnDismissInterface must be implemented by any view utilizing a ManagePrimitiveFragment.
     */
    public interface OnDismissInterface {
        void onDismiss(UserDefineObject selectedItem);
    }

    /**
     * Used to keep fragment state through attach/detach.
     */
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
    public void setOnDismissInterface(OnDismissInterface onDismissInterface) {
        mOnDismissInterface = onDismissInterface;
    }
    //endregion

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_primitive, container, false);

        int primitiveId = getArguments().getInt(ARG_PRIMITIVE_ID);
        mPrimitiveInfo = FragmentData.primitiveInfo(primitiveId);

        if (mPrimitiveInfo != null) {
            initViews(view);
            getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        }

        return view;
    }

    //region View Initialization
    private void initViews(View view) {
        initRecyclerView(view);
        initBottomBar(view);
        initToolbar(view);
    }

    private void initRecyclerView(View view) {
        mContentRecyclerView = (RecyclerView)view.findViewById(R.id.content_recycler_view);
        restoreAdapter(ManageType.Selection);

        mContentRecyclerView.setLayoutManager(new WrappedLinearLayoutManager(getActivity()));
    }

    private void initBottomBar(View view) {
        mNewItemEdit = (EditText)view.findViewById(R.id.new_item_edit);
        mNewItemEdit.setHint(getResources().getString(R.string.hint_new_item) + " " + mPrimitiveInfo.getName());

        Button addButton = (Button)view.findViewById(R.id.add_button);
        addButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = mNewItemEdit.getText().toString();

                if (!name.equals(""))
                    if (mPrimitiveInfo.getManageInterface().onAddItem(name))
                        mContentRecyclerView.getAdapter().notifyDataSetChanged();

                mNewItemEdit.setText("");
            }
        });
    }

    private void initToolbar(View view) {
        mToolbar = (Toolbar)view.findViewById(R.id.toolbar);
        restoreToolbar();
    }
    //endregion

    //region Item Management
    /**
     * Begins the editing process.
     */
    private void beginEdit() {
        showEditMenu(false);
        restoreAdapter(ManageType.Edit);
    }

    /**
     * Begins the deleting process.
     */
    private void beginDelete() {
        showEditMenu(true);
        restoreAdapter(ManageType.Delete);
    }

    /**
     * Restores the toolbar to it's default state.
     */
    private void restoreToolbar() {
        mToolbar.getMenu().clear();
        mToolbar.inflateMenu(R.menu.menu_manage_primitive);
        mToolbar.setOnMenuItemClickListener(new Toolbar.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                int id = item.getItemId();

                if (id == R.id.action_edit) {
                    beginEdit();
                    return true;
                }

                if (id == R.id.action_trash) {
                    beginDelete();
                    return true;
                }

                return false;
            }
        });
    }

    /**
     * Updates the RecyclerView's adapter to display different item layouts.
     * @param manageType The type of management item to display.
     */
    private void restoreAdapter(ManageType manageType) {
        mContentRecyclerView.setAdapter(new ManagePrimitiveAdapter(mPrimitiveInfo.getItems(), manageType));
    }

    /**
     * Shows the editing menu on the toolbar.
     * @param deleting If true, the ManagePrimitiveInfo's onConfirmDelete callback will be called.
     */
    private void showEditMenu(final boolean deleting) {
        mToolbar.getMenu().clear();
        mToolbar.inflateMenu(R.menu.menu_manage_primitive_edit);
        mToolbar.setOnMenuItemClickListener(new Toolbar.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if (item.getItemId() == R.id.action_check) {
                    if (deleting)
                        mPrimitiveInfo.getManageInterface().onConfirmDelete();

                    restoreToolbar();
                    restoreAdapter(ManageType.Selection);
                    return true;
                }
                return false;
            }
        });
    }
    //endregion

    // TODO factor holder and adapter code to it's own class
    //region RecyclerView Stuff
    private class ManagePrimitiveHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private EditText mNameEditText;
        private TextView mNameTextView;
        private CheckBox mDeleteCheckBox;
        private ManageType mManageType;

        public ManagePrimitiveHolder(View view, ManageType manageType) {
            super(view);
            view.setOnClickListener(this);
            mManageType = manageType;

            if (mManageType == ManageType.Edit)
                initForEditing(view);

            if (mManageType == ManageType.Selection)
                initForSelection(view);

            if (mManageType == ManageType.Delete)
                initForDeleting(view);
        }

        @Override
        public void onClick(View view) {
            // reset should delete if the delete selection was never confirmed
            for (UserDefineObject obj : mPrimitiveInfo.getItems())
                obj.setShouldDelete(false);

            mOnDismissInterface.onDismiss(mPrimitiveInfo.getManageInterface().onClickItem(getLayoutPosition()));
            getDialog().dismiss();
        }

        //region View Initialization
        private void initForEditing(View view) {
            mNameEditText = (EditText) view.findViewById(R.id.name_edit_text);
            mNameEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    if (mNameEditText.isFocused())
                        mPrimitiveInfo.getManageInterface().onEditItem(getAdapterPosition(), s.toString());
                }

                @Override
                public void afterTextChanged(Editable s) {}
            });
        }

        private void initForDeleting(View view) {
            initNameTextView(view);

            mDeleteCheckBox = (CheckBox) view.findViewById(R.id.delete_check_box);
            mDeleteCheckBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    Logbook.getInstance().speciesAtPos(getAdapterPosition()).setShouldDelete(isChecked);
                }
            });
        }

        private void initForSelection(View view) {
            initNameTextView(view);
        }

        private void initNameTextView(View view) {
            mNameTextView = (TextView)view.findViewById(R.id.name_text_view);
        }
        //endregion

        //region Getters & Setters
        public EditText getNameEditText() {
            return mNameEditText;
        }

        public TextView getNameTextView() {
            return mNameTextView;
        }

        public CheckBox getDeleteCheckBox() {
            return mDeleteCheckBox;
        }
        //endregion
    }

    private class ManagePrimitiveAdapter extends RecyclerView.Adapter<ManagePrimitiveHolder> {

        private List<UserDefineObject> mItems;
        private ManageType mManageType;

        public ManagePrimitiveAdapter(List<UserDefineObject> items, ManageType manageType) {
            mItems = items;
            mManageType = manageType;
        }

        @Override
        public ManagePrimitiveHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getActivity());
            int layoutId = 0;

            if      (mManageType == ManageType.Delete) layoutId = R.layout.list_item_manage_primitive_delete;
            else if (mManageType == ManageType.Selection) layoutId = R.layout.list_item_manage_primitive;
            else if (mManageType == ManageType.Edit) layoutId = R.layout.list_item_manage_primitive_edit;

            View view = inflater.inflate(layoutId, parent, false);

            return new ManagePrimitiveHolder(view, mManageType);
        }

        @Override
        public void onBindViewHolder(ManagePrimitiveHolder holder, int position) {
            UserDefineObject obj = mItems.get(position);

            if (mManageType == ManageType.Edit)
                holder.getNameEditText().setText(obj.getName());

            if (mManageType == ManageType.Selection || mManageType == ManageType.Delete)
                holder.getNameTextView().setText(obj.getName());

            if (mManageType == ManageType.Delete)
                holder.getDeleteCheckBox().setChecked(obj.getShouldDelete());
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

    }
    //endregion

}