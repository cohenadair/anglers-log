package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.ListSelectionManager;
import com.cohenadair.anglerslog.utilities.PrimitiveSpec;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The ManagePrimitiveFragment is used for selecting user defines from a list when adding new items
 * such as a {@link com.cohenadair.anglerslog.model.user_defines.Catch} or a
 * {@link com.cohenadair.anglerslog.model.user_defines.Trip}.
 *
 * @author Cohen Adair
 */
public class ManagePrimitiveFragment extends DialogFragment {

    private Context mContext;
    private RecyclerView mContentRecyclerView;
    private ManagePrimitiveAdapter mAdapter;
    private EditText mNewItemEdit;
    private Toolbar mToolbar;
    private OnDismissInterface mOnDismissInterface;
    private PrimitiveSpec mPrimitiveSpec;
    private boolean mCanSelectMultiple;

    /**
     * Used as temporary storage until the RecyclerView adapter can be initialized.
     */
    private ArrayList<UUID> mSelectedIds;

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
        void onDismissWithSelection(ArrayList<UUID> selectedIds);
        void onDismissAlways();
    }

    /**
     * Used to keep fragment state through attach/detach.
     */
    private static final String ARG_PRIMITIVE_ID = "arg_primitive_id";
    private static final String ARG_ALLOW_MULTIPLE = "arg_allow_multiple";

    public static ManagePrimitiveFragment newInstance(int primitiveId, boolean allowMultipleSelection) {
        ManagePrimitiveFragment fragment = new ManagePrimitiveFragment();

        // add primitive id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putInt(ARG_PRIMITIVE_ID, primitiveId);
        args.putBoolean(ARG_ALLOW_MULTIPLE, allowMultipleSelection);

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

    public void setSelectedIds(ArrayList<UUID> selectedIds) {
        mSelectedIds = selectedIds;
    }
    //endregion

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_primitive, container, false);

        mContext = getContext();
        mPrimitiveSpec = PrimitiveSpecManager.getSpec(getContext(), getArguments().getInt(ARG_PRIMITIVE_ID));
        mCanSelectMultiple = getArguments().getBoolean(ARG_ALLOW_MULTIPLE);

        initViews(view);
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);

        // resize the Dialog's height when the soft keyboard is shown
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);

        return view;
    }

    @Override
    public void onStop() {
        super.onStop();

        if (mOnDismissInterface != null) {
            mOnDismissInterface.onDismissAlways();
        }
    }

    public void dismissFragment() {
        // reset should delete if the delete selection was never confirmed
        for (UserDefineObject obj : mPrimitiveSpec.getItems())
            obj.setShouldDelete(false);

        mOnDismissInterface.onDismissWithSelection(mAdapter.getSelectedIds());
        getDialog().dismiss();
    }

    //region View Initialization
    private void initViews(View view) {
        initRecyclerView(view);
        initBottomBar(view);
        initToolbar(view);
    }

    private void initRecyclerView(View view) {
        mContentRecyclerView = (RecyclerView)view.findViewById(R.id.content_recycler_view);
        mContentRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        restoreAdapter(ManageType.Selection);
    }

    private void initBottomBar(View view) {
        mNewItemEdit = (EditText)view.findViewById(R.id.new_item_edit);
        mNewItemEdit.setHint(getResources().getString(R.string.hint_new_item) + " " + mPrimitiveSpec.getName());

        Button addButton = (Button)view.findViewById(R.id.add_button);
        addButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = mNewItemEdit.getText().toString();

                if (!name.equals(""))
                    if (mPrimitiveSpec.getListener().onAddItem(name))
                        restoreAdapter(ManageType.Selection);

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
        mToolbar.inflateMenu(R.menu.menu_manage);
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

        mToolbar.setNavigationIcon(R.drawable.ic_back);
        mToolbar.setNavigationContentDescription(R.string.back_description);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        // add the menu check mark when multiple selection is allowed
        if (mCanSelectMultiple)
            ViewUtils.addDoneButton(mToolbar, new MenuItem.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    dismissFragment();
                    return true;
                }
            });
    }

    /**
     * Updates the RecyclerView's adapter to display different item layouts.
     * @param manageType The type of management item to display.
     */
    private void restoreAdapter(ManageType manageType) {
        if (mAdapter != null)
            mSelectedIds = mAdapter.getSelectedIds();

        mAdapter = new ManagePrimitiveAdapter(mPrimitiveSpec.getItems(), mCanSelectMultiple, manageType);
        mAdapter.setSelectedIds(mSelectedIds);

        mContentRecyclerView.setAdapter(mAdapter);
        ViewUtils.setVisibility(mContentRecyclerView, mAdapter.getItemCount() > 0);
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
                        mAdapter.cleanUp();

                    restoreToolbar();
                    restoreAdapter(ManageType.Selection);
                    return true;
                }
                return false;
            }
        });
    }
    //endregion
    
    //region RecyclerView Stuff
    public class ManagePrimitiveHolder extends ListSelectionManager.ViewHolder {

        private int mPosition;

        private EditText mNameEditText;
        private TextView mNameTextView;
        private CheckBox mDeleteCheckBox;
        private ManageType mManageType;

        public ManagePrimitiveHolder(View view, ManageType manageType, ManagePrimitiveAdapter adapter) {
            super(view, adapter);
            mManageType = manageType;

            if (mManageType == ManageType.Edit)
                initForEditing(view);

            if (mManageType == ManageType.Selection)
                initForSelection(view);

            if (mManageType == ManageType.Delete)
                initForDeleting(view);
        }

        //region View Initialization
        private void initForEditing(View view) {
            mNameEditText = (EditText)view.findViewById(R.id.name_edit_text);
            mNameEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    if (mNameEditText.isFocused())
                        mPrimitiveSpec.getListener().onEditItem(getId(), new UserDefineObject(s.toString(), getId()));
                }

                @Override
                public void afterTextChanged(Editable s) {
                }
            });
        }

        private void initForDeleting(View view) {
            initNameTextView(view);

            mDeleteCheckBox = (CheckBox) view.findViewById(R.id.delete_check_box);
            mDeleteCheckBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    getAdapter().getItem(mPosition).setShouldDelete(isChecked);
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
        public void setPosition(int position) {
            mPosition = position;
        }

        public void setEditText(String text) {
            mNameEditText.setText(text);
        }

        public void setNameText(String text) {
            mNameTextView.setText(text);
        }

        public CheckBox getDeleteCheckBox() {
            return mDeleteCheckBox;
        }
        //endregion
    }

    public class ManagePrimitiveAdapter extends ListSelectionManager.Adapter {

        private ManageType mManageType;

        /**
         * @see com.cohenadair.anglerslog.utilities.ListSelectionManager.Adapter
         */
        public ManagePrimitiveAdapter(ArrayList<UserDefineObject> items, boolean manageSelections, ManageType manageType) {
            super(items, false, manageSelections, new OnClickInterface() {
                @Override
                public void onClick(View view, UUID id) {
                    dismissFragment();
                }
            });

            mManageType = manageType;
        }

        @Override
        public ManagePrimitiveHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getActivity());
            int layoutId = 0;

            // uses a different layout depending on the ManageType
            if      (mManageType == ManageType.Delete) layoutId = R.layout.list_item_manage_primitive_delete;
            else if (mManageType == ManageType.Selection) layoutId = R.layout.list_item_manage_primitive;
            else if (mManageType == ManageType.Edit) layoutId = R.layout.list_item_manage_primitive_edit;

            View view = inflater.inflate(layoutId, parent, false);

            return new ManagePrimitiveHolder(view, mManageType, this);
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            ManagePrimitiveHolder primitiveHolder = (ManagePrimitiveHolder)holder;
            UserDefineObject obj = getItem(position);

            super.onBind(primitiveHolder, position);
            primitiveHolder.setPosition(position);

            if (mManageType == ManageType.Edit)
                primitiveHolder.setEditText(obj.getName());

            if (mManageType == ManageType.Selection || mManageType == ManageType.Delete)
                primitiveHolder.setNameText(obj.getName());

            if (mManageType == ManageType.Delete)
                primitiveHolder.getDeleteCheckBox().setChecked(obj.getShouldDelete());
        }

        /**
         * Iterates through all the user defines and removes ones where getShouldDelete() returns true.
         */
        public void cleanUp() {
            ArrayList<UserDefineObject> items = getItems();

            for (int i = items.size() - 1; i >= 0; i--)
                if (items.get(i).getShouldDelete()) {
                    if (mPrimitiveSpec.getListener().onRemoveItem(items.get(i).getId()))
                        items.remove(i);
                    else {
                        String msg = items.get(i).getName() + " " + getResources().getString(R.string.error_delete_primitive);
                        AlertUtils.showError(mContext, msg);
                    }
                }
        }

    }
    //endregion

}
