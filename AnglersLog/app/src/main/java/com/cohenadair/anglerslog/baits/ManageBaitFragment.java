package com.cohenadair.anglerslog.baits;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MyListSelectionActivity;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectPhotosView;
import com.cohenadair.anglerslog.views.SelectionView;
import com.cohenadair.anglerslog.views.TextInputView;

import java.io.File;
import java.util.ArrayList;
import java.util.UUID;

/**
 * The ManageBaitFragment is used to add and edit baits.
 */
public class ManageBaitFragment extends ManageContentFragment {

    private Bait mNewBait;

    private SelectionView mCategoryView;
    private TextInputView mNameView;
    private SelectPhotosView mSelectPhotosView;

    public ManageBaitFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_bait, container, false);

        initCategoryView(view);
        initNameView(view);
        initSelectPhotosView(view);

        return view;
    }

    /**
     * Needed to initialize Catch and editing settings because there is ever only one instance of
     * this fragment that is reused throughout the application's lifecycle.
     */
    @Override
    public void onResume() {
        super.onResume();

        // do not initialize Catches if we were paused
        if (mNewBait == null)
            if (isEditing()) {
                Bait oldBait = Logbook.getBait(getEditingId());

                if (oldBait != null) {
                    // populate the photos view with the existing photos
                    ArrayList<String> photos = oldBait.getPhotos();
                    for (String str : photos)
                        mSelectPhotosView.addImage(PhotoUtils.privatePhotoPath(str));
                }

                mNewBait = new Bait(oldBait, true);
            } else
                mNewBait = new Bait();

        updateViews();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mNewBait = null;
    }

    @Override
    public boolean addObjectToLogbook() {
        boolean result = false;

        if (verifyUserInput()) {
            mNewBait.setPhotos(mSelectPhotosView.getImageNames());

            if (isEditing()) {
                // edit bait
                result = Logbook.editBait(getEditingId(), mNewBait);
                int msgId = result ? R.string.success_bait_edit : R.string.error_bait_edit;
                Utils.showToast(getActivity(), msgId);
            } else {
                // add catch
                result = Logbook.addBait(mNewBait);
                int msgId = result ? R.string.success_bait : R.string.error_bait;
                Utils.showToast(getActivity(), msgId);
            }
        }

        return result;
    }

    @Override
    public void onDismiss() {
        PhotoUtils.cleanPhotosAsync();
    }

    /**
     * Validates the user's input.
     * @return True if the input is valid, false otherwise.
     */
    private boolean verifyUserInput() {
        // name
        if (mNewBait.getName() == null) {
            Utils.showErrorAlert(getActivity(), R.string.error_catch_species);
            return false;
        }

        return true;
    }

    /**
     * Update the different views based on the current Catch object to display.
     */
    private void updateViews() {
        mCategoryView.setSubtitle(mNewBait.getName() != null ? mNewBait.getCategoryName() : "");
        mNameView.setInputText(mNewBait.getName() != null ? mNewBait.getName() : "");
    }

    private void initCategoryView(View view) {
        mCategoryView = (SelectionView)view.findViewById(R.id.category_layout);
        mCategoryView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(PrimitiveSpecManager.BAIT_CATEGORY);

                fragment.setOnDismissInterface(new ManagePrimitiveFragment.OnDismissInterface() {
                    @Override
                    public void onDismiss(UserDefineObject selectedItem) {
                        mNewBait.setCategory((BaitCategory)selectedItem);
                        mCategoryView.setSubtitle(mNewBait.getCategoryName());
                    }
                });

                fragment.show(getFragmentManager(), "dialog");
            }
        });
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_layout);
        mNameView.setOnEditTextChangeListener(new TextInputView.TextInputWatcher(new TextInputView.OnEditTextChangeListener() {
            @Override
            public void onTextChanged(String s) {
                mNewBait.setName(s);
            }
        }));
    }

    private void initSelectPhotosView(View view) {
        mSelectPhotosView = (SelectPhotosView)view.findViewById(R.id.select_photos_view);
        mSelectPhotosView.setSelectPhotosInteraction(new SelectPhotosView.SelectPhotosInteraction() {
            @Override
            public File onGetPhotoFile() {
                UUID id = isEditing() ? getEditingId() : null;
                return PhotoUtils.privatePhotoFile(mNewBait.getNextPhotoName(id));
            }

            @Override
            public void onStartSelectionActivity(Intent intent, int requestCode) {
                getParentFragment().startActivityForResult(intent, requestCode);
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != Activity.RESULT_OK)
            return;

        if (requestCode == REQUEST_PHOTO) {
            mSelectPhotosView.onPhotoIntentResult(data);
            return;
        }

        if (requestCode == REQUEST_SELECTION) {
            UUID id = UUID.fromString(data.getStringExtra(MyListSelectionActivity.EXTRA_SELECTED_ID));
            Log.d("ManageBaitFragment", "Selected ID: " + id.toString());
            return;
        }

        super.onActivityResult(requestCode, resultCode, data);
    }

}
