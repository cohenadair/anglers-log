package com.cohenadair.anglerslog.views;

import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.TypedArray;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.catches.ManageCatchFragment;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.PermissionUtils;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import java.io.File;
import java.util.ArrayList;

/**
 * The SelectPhotosView is used to attach or take photos. All image manipulation is done in the
 * {@link PhotoUtils} class.
 *
 * Selected or taken photos are dynamically added to a horizontal scrolling ScrollView, and can be
 * removed with a long click.
 *
 * Photos taken with the user's Camera app are saved to public device storage and can be manipulated
 * by the user outside this application. This is done so the user has a full-resolution version of
 * the photo, and so the photo is kept if the user was to uninstall this application.
 *
 * All photos (taken or selected) are downsized and copied to private application storage where
 * they are used by this application.
 *
 * @author Cohen Adair
 */
public class SelectPhotosView extends LinearLayout {

    private static final int PHOTO_ATTACH = 0;
    private static final int PHOTO_TAKE = 1;

    private InputButtonView mAddPhotoView;
    private LinearLayout mPhotosWrapper;
    private ArrayList<ImageView> mImageViews = new ArrayList<>();
    private ArrayList<String> mImagePaths = new ArrayList<>();
    private SelectPhotosInteraction mSelectPhotosInteraction;
    private File mPrivatePhotoFile; // used to save a version of the photo used by this application
    private File mPublicPhotoFile; // used to save a full resolution version of the photo for the user
    private Fragment mFragment;

    private int mMaxPhotos = -1;
    private boolean mCanSelectMultiple = false;

    public interface SelectPhotosInteraction {
        File onGetPhotoFile();
        void onStartSelectionActivity(Intent intent, int requestCode);
    }

    public SelectPhotosView(Context context) {
        this(context, null);
        init(null);
    }

    public SelectPhotosView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        View view = inflate(getContext(), R.layout.view_selection_photos, this);

        mPhotosWrapper = (LinearLayout)view.findViewById(R.id.photos_wrapper);

        mAddPhotoView = (InputButtonView)view.findViewById(R.id.add_photo_view);
        mAddPhotoView.setOnClickPrimaryButton(new OnClickListener() {
            @Override
            public void onClick(View v) {
                showPhotoOptions();
            }
        });

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.SelectPhotosView, 0, 0);
            try {
                mMaxPhotos = arr.getInt(R.styleable.SelectPhotosView_maxPhotos, -1);
                mCanSelectMultiple = arr.getBoolean(R.styleable.SelectPhotosView_canSelectMultiple, false);
            } finally {
                arr.recycle();
            }
        }

        // multiple selection is only available on API 18+
        mCanSelectMultiple = mCanSelectMultiple && Build.VERSION.SDK_INT >= 18;
        if (mCanSelectMultiple) {
            mAddPhotoView.setPrimaryButtonHint(R.string.add_photos);
        }
    }

    //region Getters & Setters
    public void setSelectPhotosInteraction(SelectPhotosInteraction onSavePhotoListener) {
        mSelectPhotosInteraction = onSavePhotoListener;
    }

    public ArrayList<String> getImageNames() {
        ArrayList<String> names = new ArrayList<>();

        for (String path : mImagePaths)
            names.add(new File(path).getName());

        return names;
    }

    public void setMaxPhotos(int maxPhotos) {
        mMaxPhotos = maxPhotos;
    }

    public void setFragment(Fragment fragment) {
        mFragment = fragment;
    }
    //endregion

    /**
     * Should be called in the associated Fragment's onRequestPermissionsResult method.
     */
    public void onStoragePermissionsGranted() {
        Intent photoIntent = PhotoUtils.takePhotoIntent();

        // make sure the camera is available on this device
        if (canTakePicture(photoIntent)) {
            if (mPublicPhotoFile != null) {
                photoIntent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(mPublicPhotoFile));
                mSelectPhotosInteraction.onStartSelectionActivity(photoIntent, ManageCatchFragment.REQUEST_PHOTO);
            } else
                Utils.showToast(getContext(), R.string.error_starting_camera);
        } else
            AlertUtils.showError(getContext(), R.string.error_camera_unavailable);
    }

    private void openPhotoIntent(int takeOrAttach) {
        mPrivatePhotoFile = mSelectPhotosInteraction.onGetPhotoFile();

        // photos taken from the camera are saved here
        mPublicPhotoFile = PhotoUtils.publicPhotoFile(mPrivatePhotoFile.getName());

        if (takeOrAttach == PHOTO_ATTACH)
            mSelectPhotosInteraction.onStartSelectionActivity(PhotoUtils.pickPhotoIntent(mCanSelectMultiple), ManageCatchFragment.REQUEST_PHOTO);

        if (takeOrAttach == PHOTO_TAKE)
            if (PermissionUtils.isExternalStorageGranted(mFragment.getContext()))
                onStoragePermissionsGranted();
            else
                // results are handled in this view's associated Fragment
                PermissionUtils.requestExternalStorage(mFragment);
    }

    public void onPhotoIntentResult(Intent data) {
        if (data != null && data.getClipData() != null)
            addMultipleImagesFromIntent(data);
        else
            addSingleImageFromIntent(data);
    }

    private void addMultipleImagesFromIntent(Intent data) {
        ClipData clip = data.getClipData();

        for (int i = 0; i < clip.getItemCount(); i++) {
            Uri photoUri = clip.getItemAt(i).getUri();
            PhotoUtils.copyAndResizePhoto(photoUri, mPrivatePhotoFile);

            if (!addImage(R.string.msg_error_attaching_photos))
                break;

            // reset file for each image
            mPrivatePhotoFile = mSelectPhotosInteraction.onGetPhotoFile();
        }
    }

    private void addSingleImageFromIntent(Intent data) {
        // scale down selected/taken photo and copy it to a private directory
        Uri photoUri = (data == null) ? Uri.fromFile(mPublicPhotoFile) : data.getData();
        PhotoUtils.copyAndResizePhoto(photoUri, mPrivatePhotoFile);

        // make sure photo taken shows up in the user's gallery
        if (mPublicPhotoFile != null && mPublicPhotoFile.exists())
            MediaScannerConnection.scanFile(getContext(), new String[]{ mPublicPhotoFile.toString() }, null, null);

        addImage(R.string.msg_error_attaching_photo);
    }

    public void addImage(String path) {
        int size = getContext().getResources().getDimensionPixelSize(R.dimen.thumbnail_cell_size);

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(size, size);
        layoutParams.setMargins(0, 0, 0, getContext().getResources().getDimensionPixelSize(R.dimen.margin_default));

        final ImageView img = new ImageView(getContext());
        img.setContentDescription("Image-" + mImageViews.size());
        img.setLayoutParams(layoutParams);
        img.setOnLongClickListener(new OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                AlertUtils.showDeleteConfirmation(getContext(), R.string.msg_delete_photo, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        removeImage(img);
                    }
                });
                return false;
            }
        });
        PhotoUtils.thumbnailToImageView(img, path, size, R.drawable.placeholder_square);

        mImageViews.add(img);
        mImagePaths.add(path);
        updateImageMargins();

        mPhotosWrapper.addView(img);

        // manage max photos
        if (mMaxPhotos != -1)
            if (mPhotosWrapper.getChildCount() >= mMaxPhotos)
                disableCamera();
    }

    public boolean addImage(int errMsgId) {
        if (mPrivatePhotoFile == null) {
            Utils.showToast(getContext(), errMsgId);
            return false;
        } else {
            addImage(mPrivatePhotoFile.getPath());
            return true;
        }
    }

    private void removeImage(ImageView img) {
        mImagePaths.remove(mImageViews.indexOf(img));
        mImageViews.remove(img);
        mPhotosWrapper.removeView(img);

        // manage max photos
        if (mMaxPhotos != -1)
            if (mPhotosWrapper.getChildCount() < mMaxPhotos)
                enableCamera();
    }

    /**
     * Updates the right margin of each ImageView to simulate spacing.
     */
    private void updateImageMargins() {
        for (int i = 0; i < mImageViews.size() - 1; i++) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)mImageViews.get(i).getLayoutParams();
            params.setMargins(0, 0, getResources().getDimensionPixelSize(R.dimen.spacing_small), 0);
        }
    }

    private boolean canTakePicture(Intent intent) {
        return (mPrivatePhotoFile != null) && (intent.resolveActivity(getContext().getPackageManager()) != null);
    }

    private void enableCamera() {
        mAddPhotoView.setEnabled(true);
    }

    private void disableCamera() {
        mAddPhotoView.setEnabled(false);
    }

    private void showPhotoOptions() {
        if (!mAddPhotoView.isEnabled())
            return;

        int options = mCanSelectMultiple ? R.array.add_photo_options : R.array.add_photo_options_single;

        new AlertDialog.Builder(getContext())
                .setPositiveButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setItems(options, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        openPhotoIntent(which);
                    }
                })
                .show();
    }

}
