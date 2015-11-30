package com.cohenadair.anglerslog.fragments;

import android.app.Activity;
import android.content.Intent;
import android.support.v4.app.Fragment;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MyListSelectionActivity;
import com.cohenadair.anglerslog.model.user_defines.PhotoUserDefineObject;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectPhotosView;

import java.io.File;
import java.util.ArrayList;
import java.util.UUID;

/**
 * The ManageContentFragment is the superclass of the content fragments used in ManageFragment
 * instances.
 *
 * Created by Cohen Adair on 2015-09-30.
 */
public abstract class ManageContentFragment extends Fragment {

    public static final int REQUEST_PHOTO = 0;
    public static final int REQUEST_SELECTION = 1;

    private SelectPhotosView mSelectPhotosView;
    private UserDefineObject mNewObject;

    private boolean mIsEditing;
    private UUID mEditingId;
    private OnSelectionActivityResult mOnSelectionActivityResult;

    /**
     * Updates each view; normally used for editing.
     */
    public abstract void updateViews();

    /**
     * Gets a {@link com.cohenadair.anglerslog.fragments.ManageContentFragment.ManageObjectSpec}
     * for the current subclass.
     *
     * @return The ManageObjectSpec object.
     */
    public abstract ManageObjectSpec getManageObjectSpec();

    /**
     * Initializes the subclass's UserDefineObject subclass.
     */
    public abstract void initSubclassObject();

    /**
     * Ensures the user input is correct.
     * @return True if everything is valid; false otherwise.
     */
    public abstract boolean verifyUserInput();

    /**
     * Used as a callback for {@link MyListSelectionActivity} instances.
     */
    public interface OnSelectionActivityResult {
        void onSelect(UUID id);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mNewObject = null;
    }

    @Override
    public void onResume() {
        super.onResume();

        // do not initialize Catches if we were paused
        if (getNewObject() == null)
            initSubclassObject();

        updateViews();
    }

    //region Getters & Setters
    public boolean isEditing() {
        return mIsEditing;
    }

    public void setIsEditing(boolean isEditing, UUID itemId) {
        mIsEditing = isEditing;
        mEditingId = itemId;
    }

    public UUID getEditingId() {
        return mEditingId;
    }

    public SelectPhotosView getSelectPhotosView() {
        return mSelectPhotosView;
    }

    public UserDefineObject getNewObject() {
        return mNewObject;
    }
    //endregion

    public void onDismiss() {
        // only clean photos if this class implements a SelectPhotosView
        if (mSelectPhotosView != null)
            PhotoUtils.cleanPhotosAsync();
    }

    /**
     * Initializes the SelectPhotosView. This method should only be called by subclasses that
     * implement a {@link SelectPhotosView} such as a
     * {@link com.cohenadair.anglerslog.catches.ManageCatchFragment}.
     *
     * @param view The View object being initialized.
     */
    protected void initSelectPhotosView(View view) {
        mSelectPhotosView = (SelectPhotosView)view.findViewById(R.id.select_photos_view);
        mSelectPhotosView.setSelectPhotosInteraction(new SelectPhotosView.SelectPhotosInteraction() {
            @Override
            public File onGetPhotoFile() {
                UUID id = isEditing() ? getEditingId() : null;
                return PhotoUtils.privatePhotoFile(((PhotoUserDefineObject)mNewObject).getNextPhotoName(id));
            }

            @Override
            public void onStartSelectionActivity(Intent intent, int requestCode) {
                getParentFragment().startActivityForResult(intent, requestCode);
            }
        });
    }

    /**
     * A simple interface used for initializing the current UserDefineObject and used as a
     * parameter in {@link #initObject(InitializeInterface)}.
     */
    public interface InitializeInterface {
        UserDefineObject onGetOldObject();
        UserDefineObject onGetNewEditObject(UserDefineObject oldObject);
        UserDefineObject onGetNewBlankObject();
    }

    /**
     * Initializes the current UserDefineObject.
     *
     * @param init The {@link com.cohenadair.anglerslog.fragments.ManageContentFragment.InitializeInterface}
     *             used to initialize the UserDefineObject.
     */
    protected void initObject(InitializeInterface init) {
        if (isEditing()) {
            UserDefineObject oldObject = init.onGetOldObject();

            // if the UserDefineObject has photos
            if (oldObject != null && (oldObject instanceof PhotoUserDefineObject)) {
                // populate the photos view with the existing photos
                ArrayList<String> photos = ((PhotoUserDefineObject)oldObject).getPhotos();
                for (String str : photos)
                    getSelectPhotosView().addImage(PhotoUtils.privatePhotoPath(str));
            }

            mNewObject = init.onGetNewEditObject(oldObject);
        } else
            mNewObject = init.onGetNewBlankObject();
    }

    /**
     * Adds the current UserDefineObject to the Logbook. The type of object and methods to be called
     * are specified in the subclass's {@link #getManageObjectSpec()} method.
     *
     * @return True if the object was successfully added/updated; false otherwise.
     */
    public boolean addObjectToLogbook() {
        boolean result = false;
        ManageObjectSpec spec = getManageObjectSpec();

        if (verifyUserInput()) {
            ArrayList<String> s = getSelectPhotosView().getImageNames();
            if (mSelectPhotosView != null)
                ((PhotoUserDefineObject)mNewObject).setPhotos(getSelectPhotosView().getImageNames());

            if (isEditing()) {
                // edit object
                result = spec.edit();
                int msgId = result ? spec.getEditSuccess() : spec.getEditError();
                Utils.showToast(getActivity(), msgId);
            } else {
                // add object
                result = spec.add();
                int msgId = result ? spec.getAddSuccess() : spec.getAddError();
                Utils.showToast(getActivity(), msgId);
            }
        }

        return result;
    }

    public void startSelectionActivity(int layoutId, OnSelectionActivityResult onSelect) {
        mOnSelectionActivityResult = onSelect;

        Intent intent = new Intent(getContext(), MyListSelectionActivity.class);
        intent.putExtra(MyListSelectionActivity.EXTRA_LAYOUT_ID, layoutId);
        intent.putExtra(MyListSelectionActivity.EXTRA_TWO_PANE, Utils.isTwoPane(getActivity()));
        getParentFragment().startActivityForResult(intent, REQUEST_SELECTION);
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
            mOnSelectionActivityResult.onSelect(UUID.fromString(data.getStringExtra(MyListSelectionActivity.EXTRA_SELECTED_ID)));
            return;
        }

        updateViews();
        super.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * The ManageInterface and ManageObjectSpec is used to minimize repeated code in
     * ManageContentFragment subclasses since the managing code is virtually identical.
     */
    protected interface ManageInterface {
        boolean onEdit();
        boolean onAdd();
    }

    protected class ManageObjectSpec {

        private int mAddError;
        private int mAddSuccess;
        private int mEditError;
        private int mEditSuccess;

        private ManageInterface mManageInterface;

        public ManageObjectSpec(int addError, int addSuccess, int editError, int editSuccess, ManageInterface manageInterface) {
            mAddError = addError;
            mAddSuccess = addSuccess;
            mEditError = editError;
            mEditSuccess = editSuccess;
            mManageInterface = manageInterface;
        }

        public boolean edit() {
            return mManageInterface.onEdit();
        }

        public boolean add() {
            return mManageInterface.onAdd();
        }

        public int getAddError() {
            return mAddError;
        }

        public int getAddSuccess() {
            return mAddSuccess;
        }

        public int getEditError() {
            return mEditError;
        }

        public int getEditSuccess() {
            return mEditSuccess;
        }
    }
}
