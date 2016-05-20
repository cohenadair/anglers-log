package com.cohenadair.anglerslog.fragments;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.view.View;
import android.widget.DatePicker;
import android.widget.TimePicker;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MyListSelectionActivity;
import com.cohenadair.anglerslog.model.user_defines.PhotoUserDefineObject;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.PermissionUtils;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectPhotosView;

import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.UUID;

/**
 * The ManageContentFragment is the superclass of the content fragments used in ManageFragment
 * instances.
 *
 * @author Cohen Adair
 */
public abstract class ManageContentFragment extends Fragment {

    public static final int REQUEST_PHOTO = 0;
    public static final int REQUEST_SELECTION = 1;

    private SelectPhotosView mSelectPhotosView;
    private UserDefineObject mNewObject;
    private UserDefineObject mOldObject;

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
        void onSelect(ArrayList<String> ids);
    }

    /**
     * Used as a callback for {@link DatePickerFragment} and {@link TimePickerFragment}.
     */
    public interface DateTimePickerInterface {
        void onFinish(Date date);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mNewObject = null;
        mOldObject = null;
    }

    @Override
    public void onResume() {
        super.onResume();

        // do not initialize if we were paused
        if (getNewObject() == null)
            initSubclassObject();

        updateViews();
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        // for taking photos
        if (requestCode == PermissionUtils.REQUEST_EXTERNAL_STORAGE) {
            if (grantResults.length > 0 && grantResults[0] == PermissionUtils.GRANTED)
                mSelectPhotosView.onStoragePermissionsGranted();
            else
                AlertUtils.showError(getContext(), R.string.storage_permissions_denied);

            return;
        }

        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
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

    /**
     * Checks to see if, when editing, the new object and old object names are different.
     * @return True if the names are different, false otherwise.
     */
    public boolean isNameDifferent() {
        return !isEditing() || (!(mNewObject == null || mOldObject == null) && !mNewObject.getName().equals(mOldObject.getName()));
    }

    public void onDismiss() {
        // called elsewhere; empty to avoid runtime errors
        // some subclasses override this method
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
        mSelectPhotosView.setFragment(this.getParentFragment());
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
        if (init == null)
            return;

        if (isEditing()) {
            mOldObject = init.onGetOldObject();

            // if the UserDefineObject has photos
            if (mOldObject != null && (mOldObject instanceof PhotoUserDefineObject)) {
                // populate the photos view with the existing photos
                ArrayList<String> photos = ((PhotoUserDefineObject)mOldObject).getPhotos();
                for (String str : photos)
                    getSelectPhotosView().addImage(PhotoUtils.privatePhotoPath(str));
            }

            mNewObject = (mOldObject != null) ? init.onGetNewEditObject(mOldObject) : init.onGetNewBlankObject();
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

    /**
     * Starts a new activity for selecting non-primitive UserDefineObjects, such as Catches or
     * Locations.
     *
     * @param layoutId The layout id to show. See {@link com.cohenadair.anglerslog.utilities.LayoutSpecManager}.
     * @param cancelSpecOnSelection True to cancel {@link com.cohenadair.anglerslog.utilities.LayoutSpec.OnSelectionListener}, false otherwise.
     * @param multipleSelection True if the user can select multiple items, false otherwise.
     * @param selectedIds Array of String ids that should already be selected. This can be null.
     * @param onResult A callback for when the user is finished selecting.
     */
    public void startSelectionActivity(int layoutId, boolean cancelSpecOnSelection, boolean multipleSelection, ArrayList<String> selectedIds, OnSelectionActivityResult onResult) {
        mOnSelectionActivityResult = onResult;

        Intent intent = new Intent(getContext(), MyListSelectionActivity.class);
        intent.putExtra(MyListSelectionActivity.EXTRA_CANCEL_SELECTION_INTERFACE, cancelSpecOnSelection);
        intent.putExtra(MyListSelectionActivity.EXTRA_MULTIPLE_SELECTION, multipleSelection);
        intent.putExtra(MyListSelectionActivity.EXTRA_SELECTED_IDS, selectedIds);
        intent.putExtra(MyListSelectionActivity.EXTRA_LAYOUT_ID, layoutId);
        intent.putExtra(MyListSelectionActivity.EXTRA_TWO_PANE, Utils.isTwoPane(getActivity()));

        getParentFragment().startActivityForResult(intent, REQUEST_SELECTION);
    }

    /**
     * Wrapper function for {@link #startSelectionActivity(int, boolean, boolean, ArrayList, OnSelectionActivityResult)}.
     * Shows a {@link MyListSelectionActivity} with default settings.
     */
    public void startSelectionActivity(int layoutId, OnSelectionActivityResult onResult) {
        startSelectionActivity(layoutId, false, false, null, onResult);
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
            if (mOnSelectionActivityResult != null)
                mOnSelectionActivityResult.onSelect(
                        data.getStringArrayListExtra(MyListSelectionActivity.EXTRA_SELECTED_IDS)
                );
            return;
        }

        updateViews();
        super.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * Shows the manager fragment for the specified primitive {@link UserDefineObject}.
     *
     * @param primitiveId The primitive id. See {@link com.cohenadair.anglerslog.utilities.PrimitiveSpecManager}.
     * @param multiple True if multiple selection is allowed, false otherwise.
     * @param selectedIds UUID of the items that should already be selected. This can be null.
     * @param onDismissInterface Callbacks for when the manager is dismissed.
     */
    public void showPrimitiveDialog(int primitiveId, boolean multiple, ArrayList<UUID> selectedIds, ManagePrimitiveFragment.OnDismissInterface onDismissInterface) {
        ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(primitiveId, multiple);

        if (multiple)
            fragment.setSelectedIds(selectedIds);

        fragment.setOnDismissInterface(onDismissInterface);
        fragment.show(getChildFragmentManager(), "PrimitiveDialog");
    }

    /**
     * Shows a {@link DatePickerFragment}.
     *
     * @param calendarUpdateDate The date to update the global calendar to.
     * @param callbacks See {@link com.cohenadair.anglerslog.fragments.ManageContentFragment.DateTimePickerInterface}.
     */
    public void showDatePickerFragment(final Date calendarUpdateDate, final DateTimePickerInterface callbacks) {
        DatePickerFragment datePicker = new DatePickerFragment();
        datePicker.setOnDateSetListener(new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                updateCalendar(calendarUpdateDate);
                Calendar c = Calendar.getInstance();
                int hours = c.get(Calendar.HOUR_OF_DAY);
                int minutes = c.get(Calendar.MINUTE);
                c.set(year, monthOfYear, dayOfMonth, hours, minutes);
                callbacks.onFinish(c.getTime());
            }
        });
        datePicker.setInitialDate(calendarUpdateDate);
        datePicker.show(getFragmentManager(), "datePicker");
    }

    /**
     * Shows a {@link TimePickerFragment}.
     *
     * @param calendarUpdateDate The date to update the global calendar to.
     * @param callbacks See {@link com.cohenadair.anglerslog.fragments.ManageContentFragment.DateTimePickerInterface}.
     */
    public void showTimePickerFragment(final Date calendarUpdateDate, final DateTimePickerInterface callbacks) {
        TimePickerFragment timePicker = new TimePickerFragment();
        timePicker.setOnTimeSetListener(new TimePickerDialog.OnTimeSetListener() {
            @Override
            public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
                updateCalendar(calendarUpdateDate);
                Calendar c = Calendar.getInstance();
                int year = c.get(Calendar.YEAR);
                int month = c.get(Calendar.MONTH);
                int day = c.get(Calendar.DAY_OF_MONTH);
                c.set(year, month, day, hourOfDay, minute);
                callbacks.onFinish(c.getTime());
            }
        });
        timePicker.setInitialDate(calendarUpdateDate);
        timePicker.show(getFragmentManager(), "timePicker");
    }

    /**
     * Resets the calendar's time to the current catch's time.
     */
    private void updateCalendar(Date date) {
        Calendar.getInstance().setTime(date);
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
