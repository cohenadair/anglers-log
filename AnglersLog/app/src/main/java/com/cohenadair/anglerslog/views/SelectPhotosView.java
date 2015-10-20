package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v7.app.AlertDialog;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
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
 * Created by Cohen Adair on 2015-10-18.
 */
public class SelectPhotosView extends LinearLayout {

    public static final int REQUEST_PHOTO = 0;

    private static final int PHOTO_ATTACH = 0;
    private static final int PHOTO_TAKE = 1;

    private LinearLayout mPhotosWrapper;
    private ArrayList<ImageView> mImageViews = new ArrayList<>();
    private SelectPhotosInteraction mSelectPhotosInteraction;
    private File mPrivatePhotoFile; // used to save a version of the photo used by this application
    private File mPublicPhotoFile; // used to save a full resolution version of the photo for the user

    public interface SelectPhotosInteraction {
        File onGetPhotoFile();
        void onStartSelectionActivity(Intent intent, int requestCode);
        void onAddImage();
        void onRemoveImage(int position);
    }

    public SelectPhotosView(Context context) {
        this(context, null);
        init();
    }

    public SelectPhotosView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        View view = inflate(getContext(), R.layout.view_selection_photos, this);

        mPhotosWrapper = (LinearLayout)view.findViewById(R.id.photos_wrapper);

        ImageButton cameraButton = (ImageButton)view.findViewById(R.id.camera_button);
        cameraButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                new AlertDialog.Builder(getContext())
                        .setPositiveButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                            }
                        })
                        .setItems(R.array.add_photo_options, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                openPhotoIntent(which);
                            }
                        })
                        .show();
            }
        });
    }

    //region Getters & Setters
    public void setSelectPhotosInteraction(SelectPhotosInteraction onSavePhotoListener) {
        mSelectPhotosInteraction = onSavePhotoListener;
    }
    //endregion

    private void openPhotoIntent(int takeOrAttach) {
        mPrivatePhotoFile = mSelectPhotosInteraction.onGetPhotoFile();

        // photos taken from the camera are saved here
        mPublicPhotoFile = PhotoUtils.publicPhotoFile(getContext(), mPrivatePhotoFile.getName());

        if (takeOrAttach == PHOTO_ATTACH)
            mSelectPhotosInteraction.onStartSelectionActivity(PhotoUtils.pickPhotoIntent(getContext()), REQUEST_PHOTO);

        if (takeOrAttach == PHOTO_TAKE) {
            Intent photoIntent = PhotoUtils.takePhotoIntent();

            // make sure the camera is available on this device
            if (canTakePicture(photoIntent)) {
                photoIntent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(mPublicPhotoFile));
                mSelectPhotosInteraction.onStartSelectionActivity(photoIntent, REQUEST_PHOTO);
            } else
                Utils.showErrorAlert(getContext(), R.string.error_camera_unavailable);
        }
    }

    public void onPhotoIntentResult(Intent data) {
        // scale down selected/taken photo and copy it to a private directory
        Uri photoUri = (data == null) ? Uri.fromFile(mPublicPhotoFile) : data.getData();
        PhotoUtils.copyAndResizePhoto(getContext(), photoUri, mPrivatePhotoFile);

        // make sure photo taken shows up in the user's gallery
        if (mPublicPhotoFile.exists())
            MediaScannerConnection.scanFile(getContext(), new String[] { mPublicPhotoFile.toString() }, null, null);

        addImage(mPrivatePhotoFile.getPath());
        mSelectPhotosInteraction.onAddImage();
    }

    public void addImage(String path) {
        int size = getContext().getResources().getDimensionPixelSize(R.dimen.thumbnail_size);

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(size, size);
        layoutParams.setMargins(0, getResources().getDimensionPixelSize(R.dimen.spacing_small_half), 0, 0);

        final ImageView img = new ImageView(getContext());
        img.setLayoutParams(layoutParams);
        img.setBackgroundResource(R.color.anglers_log_dark);
        img.setOnLongClickListener(new OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                Utils.showDeleteOption(getContext(), R.string.msg_delete_photo, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        removeImage(img);
                    }
                });
                return false;
            }
        });
        PhotoUtils.thumbnailToImageView(getContext(), img, path, size, R.drawable.no_catch_photo);

        mImageViews.add(img);
        updateImageMargins();

        mPhotosWrapper.addView(img);
    }

    private void removeImage(ImageView img) {
        mSelectPhotosInteraction.onRemoveImage(mImageViews.indexOf(img));
        mImageViews.remove(img);
        mPhotosWrapper.removeView(img);
    }

    private void updateImageMargins() {
        for (int i = 0; i < mImageViews.size() - 1; i++) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)mImageViews.get(i).getLayoutParams();
            params.setMargins(0, getResources().getDimensionPixelSize(R.dimen.spacing_small_half), getResources().getDimensionPixelSize(R.dimen.spacing_medium), 0);
        }
    }

    private boolean canTakePicture(Intent intent) {
        return (mPrivatePhotoFile != null) && (intent.resolveActivity(getContext().getPackageManager()) != null);
    }

}
