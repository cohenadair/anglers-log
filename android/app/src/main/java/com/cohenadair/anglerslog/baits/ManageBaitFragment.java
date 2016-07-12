package com.cohenadair.anglerslog.baits;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.trips.ManageTripFragment;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.InputButtonView;
import com.cohenadair.anglerslog.views.InputTextView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The ManageBaitFragment is used to add and edit baits.
 */
public class ManageBaitFragment extends ManageContentFragment {

    private InputButtonView mCategoryView;
    private InputTextView mNameView;
    private InputTextView mColorView;
    private InputTextView mSizeView;
    private InputTextView mDescriptionView;
    private Spinner mTypeSpinner;

    public ManageBaitFragment() {
        // Required empty public constructor
    }

    private Bait getNewBait() {
        return (Bait)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_bait, container, false);

        initCategoryView(view);
        initNameView(view);
        initSelectPhotosView(view);
        initSpinner(view);
        initColorView(view);
        initSizeView(view);
        initDescriptionView(view);
        initSubclassObject();

        getSelectPhotosView().setMaxPhotos(1);

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        initInputListeners();
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_bait, R.string.success_bait, R.string.error_bait_edit, R.string.success_bait_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editBait(getEditingId(), getNewBait());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addBait(getNewBait());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getBait(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                return new Bait((Bait)oldObject, true);
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Bait();
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        // category is set in the TitleSubtitleView interface
        // type is set in the Spinner interface
        // input properties are set in a OnTextChanged listener

        // category
        if (getNewBait().getCategory() == null) {
            AlertUtils.showError(getActivity(), R.string.error_bait_category);
            return false;
        }

        // name
        if (getNewBait().isNameNull()) {
            AlertUtils.showError(getActivity(), R.string.error_name);
            return false;
        }

        // name and category combo
        if (isNameDifferent() && Logbook.baitExists(getNewBait())) {
            AlertUtils.showError(getActivity(), R.string.error_bait_category_name);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mCategoryView.setPrimaryButtonText(getNewBait().getBaitCategoryAsString());
        mNameView.setInputText(getNewBait().getNameAsString());
        mColorView.setInputText(getNewBait().getColorAsString());
        mSizeView.setInputText(getNewBait().getSizeAsString());
        mDescriptionView.setInputText(getNewBait().getDescriptionAsString());
        mTypeSpinner.setSelection(getNewBait().getType());
    }

    private void initCategoryView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UUID> selectedIds) {
                getNewBait().setCategory(Logbook.getBaitCategory(selectedIds.get(0)));
                mCategoryView.setPrimaryButtonText(getNewBait().getCategoryName());
            }
        };

        mCategoryView = (InputButtonView)view.findViewById(R.id.category_view);
        mCategoryView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showCategoryDialog(onDismissInterface);
            }
        });
    }

    /**
     * Shows an instance of {@link ManagePrimitiveFragment} allowing the user to select a
     * {@link com.cohenadair.anglerslog.model.user_defines.BaitCategory}.
     *
     * @param onDismissInterface Callbacks for when a selection is made.
     */
    private void showCategoryDialog(ManagePrimitiveFragment.OnDismissInterface onDismissInterface) {
        ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(PrimitiveSpecManager.BAIT_CATEGORY, false);
        fragment.setOnDismissInterface(onDismissInterface);
        fragment.show(getFragmentManager(), "dialog");
    }

    private void initNameView(View view) {
        mNameView = (InputTextView)view.findViewById(R.id.name_view);
    }

    private void initColorView(View view) {
        mColorView = (InputTextView)view.findViewById(R.id.color_view);
    }

    private void initSizeView(View view) {
        mSizeView = (InputTextView)view.findViewById(R.id.size_view);
    }

    private void initDescriptionView(View view) {
        mDescriptionView = (InputTextView)view.findViewById(R.id.description_view);
    }

    private void initSpinner(View view) {
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getContext(), R.array.bait_types, R.layout.list_item_spinner);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mTypeSpinner = (Spinner)view.findViewById(R.id.type_spinner);
        mTypeSpinner.setAdapter(adapter);
        mTypeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                getNewBait().setType(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    /**
     * See {@link ManageTripFragment#initInputListeners()}.
     */
    private void initInputListeners() {
        mNameView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setName(newText);
            }
        }));

        mDescriptionView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setDescription(newText);
            }
        }));

        mSizeView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setSize(newText);
            }
        }));

        mColorView.addOnInputTextChangedListener(ViewUtils.onTextChangedListener(new ViewUtils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setColor(newText);
            }
        }));
    }

}
