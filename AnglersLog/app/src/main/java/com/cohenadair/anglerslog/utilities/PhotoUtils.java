package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.media.ThumbnailUtils;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.R;

import java.io.File;
import java.io.IOException;

/**
 * Any utility functions that have anything to do with photos/photo manipulation.
 * Created by Cohen Adair on 2015-10-18.
 */
public class PhotoUtils {

    private static final String TAG = "PhotoUtils";

    private PhotoUtils() {

    }

    @NonNull
    public static Intent pickPhotoIntent(@NonNull Context context) {
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        return Intent.createChooser(intent, context.getResources().getString(R.string.select_photo));
    }

    @NonNull
    public static Intent takePhotoIntent() {
        return new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    }

    /**
     * Scales the image at the specified path to the specified dimension.
     * @param path The path to the image to scale.
     * @param destWidth The destination width.
     * @param destHeight The destination height.
     * @return A Bitmap object of the new
     */
    public static Bitmap scaledBitmap(String path, int destWidth, int destHeight) {
        // read in the dimensions of the image on disk
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, options);

        float srcWidth = options.outWidth;
        float srcHeight = options.outHeight;

        // figure out how much to scale by
        int inSampleSize = 1;
        if (srcHeight > destHeight || srcWidth > destWidth)
            if (srcWidth > srcHeight)
                inSampleSize = Math.round(srcHeight / destHeight);
            else
                inSampleSize = Math.round(srcWidth / destWidth);

        options = new BitmapFactory.Options();
        options.inSampleSize = inSampleSize;

        // read in and create the final bitmap
        return fixOrientation(path, BitmapFactory.decodeFile(path, options));
    }

    public static Bitmap thumbnail(String path, int size) {
        Bitmap bitmap = scaledBitmap(path, size, size);
        return ThumbnailUtils.extractThumbnail(bitmap, size, size, ThumbnailUtils.OPTIONS_RECYCLE_INPUT);
    }

    public static Bitmap fixOrientation(String path, Bitmap bmp) {
        try {
            ExifInterface exif = new ExifInterface(path);
            int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED);

            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    bmp = rotateBitmap(bmp, 90);
                    break;

                case ExifInterface.ORIENTATION_ROTATE_180:
                    bmp = rotateBitmap(bmp, 180);
                    break;

                case ExifInterface.ORIENTATION_ROTATE_270:
                    bmp = rotateBitmap(bmp, 270);
                    break;
            }

        } catch (IOException e) {
            Log.d(TAG, "Error extracting ExifInterface from file: " + path);
            e.printStackTrace();
        }

        return bmp;
    }

    public static Bitmap rotateBitmap(Bitmap bmp, int degrees) {
        Matrix matrix = new Matrix();
        matrix.postRotate(degrees);
        return Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(), matrix, true);
    }

    /**
     * Gets a pointer to a file where a new photo can be saved.
     * @param context The Context used to find the new file location.
     * @param fileName The name of the new photo.
     * @return A File object pointing to the photo's storage location.
     */
    @Nullable
    public static File photoFile(Context context, String fileName) {
        File externalFilesDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);

        if (externalFilesDir == null)
            return null;

        return new File(externalFilesDir, fileName);
    }

    /**
     * Gets the full path to the specified file name.
     * @param context The context in which to create the path.
     * @param fileName The name of the file to get.
     * @return A String of the file's path.
     */
    public static String photoPath(Context context, String fileName) {
        File f = photoFile(context, fileName);
        return (f == null) ? null : f.getPath();
    }

    /**
     * Deletes the photo at the specified path.
     * @param context The context in which to delete the photo.
     * @param path The path of the photo to delete.
     * @return True if the photo was deleted, false otherwise.
     */
    public static boolean deletePhoto(Context context, String path) {
        File f = photoFile(context, path);
        return (f == null) || f.delete();
    }

}
