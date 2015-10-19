package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.ExifInterface;
import android.media.ThumbnailUtils;
import android.os.AsyncTask;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.ImageView;

import com.cohenadair.anglerslog.R;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;

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
     * Scales the image at the specified path to the specified dimension. This method should be
     * executed away from the UI thread.
     * @param path The path to the image to scale.
     * @param destWidth The destination width.
     * @param destHeight The destination height.
     * @return A Bitmap object of the new
     */
    private static Bitmap scaledBitmap(String path, int destWidth, int destHeight) {
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

    /**
     * Takes a photo at a given path, scales it, and inserts it in to the given ImageView.
     * @param imageView The ImageView to show the photo.
     * @param path The path to the photo.
     * @param width The width of the ImageView, in pixels.
     * @param height The height of the ImageView, in pixels.
     */
    public static void photoToImageView(ImageView imageView, String path, int width, int height) {
        BitmapAsyncTask task = new BitmapAsyncTask(imageView, width, height, false);
        task.execute(path);
    }

    /**
     * Takes a photo at a given path, scales it, generates a thumbnail, and inserts into the given
     * ImageView.
     * @param imageView The ImageView to display the thumbnail.
     * @param path The path to the photo.
     * @param size The size of the ImageView, in pixels.
     */
    public static void thumbnailToImageView(Context context, ImageView imageView, String path, int size, int placeHolderResId) {
        Bitmap placeHolder = BitmapFactory.decodeResource(context.getResources(), placeHolderResId);

        if (cancelPotentialWork(path, imageView)) {
            final BitmapAsyncTask task = new BitmapAsyncTask(imageView, size, size, true);
            final AsyncDrawable asyncDrawable = new AsyncDrawable(context.getResources(), placeHolder, task);
            imageView.setImageDrawable(asyncDrawable);
            task.execute(path);
        }
    }

    private static Bitmap fixOrientation(String path, Bitmap bmp) {
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

    private static Bitmap rotateBitmap(Bitmap bmp, int degrees) {
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

    //region Async Bitmap Utilities
    /**
     * This section was created from the Android tutorial,
     * <a href="http://developer.android.com/training/displaying-bitmaps/index.html">Displaying Bitmaps Efficiently</a>.
     */

    /**
     * The BitmapAsyncTask class is used to scale and/or generate a thumbnail for the image at
     * a given path and insert that bitmap into the given ImageView.
     *
     * This is required so the UI thread isn't locked up while loading Bitmap objects.
     */
    private static class BitmapAsyncTask extends AsyncTask<String, Void, Bitmap> {
        private final WeakReference<ImageView> mImageViewRef;
        private String mPath = null;
        private int mWidth, mHeight;
        private boolean mGenerateThumb;

        /**
         * Sets up the AsyncTask for execution.
         * @param imageView The ImageView that holds the new Bitmap.
         * @param width The width of the scaled Bitmap, in pixels.
         * @param height The height of the scaled Bitmap, in Pixels.
         * @param thumb True to use a thumbnail image (square), false for original size ratio.
         */
        public BitmapAsyncTask(ImageView imageView, int width, int height, boolean thumb) {
            mImageViewRef = new WeakReference<>(imageView);
            mWidth = width;
            mHeight = height;
            mGenerateThumb = thumb;
        }

        @Override
        protected Bitmap doInBackground(String... params) {
            mPath = params[0];
            Bitmap scaledBitmap = scaledBitmap(mPath, mWidth, mHeight);

            // get thumbnail if needed
            if (mGenerateThumb) {
                int size = (mWidth > mHeight) ? mHeight : mWidth; // get the smaller of the width/height
                return ThumbnailUtils.extractThumbnail(scaledBitmap, size, size);
            }

            return scaledBitmap;
        }

        @Override
        protected void onPostExecute(Bitmap bitmap) {
            if (isCancelled())
                bitmap = null;

            if (bitmap != null) {
                final ImageView imageView = mImageViewRef.get();
                final BitmapAsyncTask bitmapAsyncTask = bitmapAsyncTask(imageView);

                if (this == bitmapAsyncTask)
                    imageView.setImageBitmap(bitmap);
            }
        }

        public String getPath() {
            return mPath;
        }
    }

    /**
     * The AsyncDrawable class is used so the ImageView can store a reference back to it's
     * BitmapAsyncTask. A BitmapDrawable is used so that a placeholder image can be displayed in the
     * ImageView while the task is being completed.
     */
    private static class AsyncDrawable extends BitmapDrawable {
        private final WeakReference<BitmapAsyncTask> mBitmapAsyncTaskRef;

        public AsyncDrawable(Resources resources, Bitmap bitmap, BitmapAsyncTask bitmapAsyncTask) {
            super(resources, bitmap);
            mBitmapAsyncTaskRef = new WeakReference<>(bitmapAsyncTask);
        }

        public BitmapAsyncTask getBitmapAsyncTask() {
            return mBitmapAsyncTaskRef.get();
        }
    }

    /**
     * Checks to see if another running task is already associated with the given ImageView. If so,
     * it attempts to cancel the task. In a small number of cases the new task will match an
     * existing task (such as in a ListView or GridView).
     *
     * @param path The path of the photo.
     * @param imageView The ImageView to check for BitmapAsyncTask.
     * @return True if there is no task associated with the ImageView, or the task was cancelled,
     * false otherwise.
     */
    private static boolean cancelPotentialWork(String path, ImageView imageView) {
        final BitmapAsyncTask bitmapAsyncTask = bitmapAsyncTask(imageView);

        if (bitmapAsyncTask != null) {
            final String bitmapPath = bitmapAsyncTask.getPath();

            // if the path is not yet set or it differs from the new data
            if (bitmapPath == null || !bitmapPath.equals(path))
                // cancel previous task
                bitmapAsyncTask.cancel(true);
            else
                // the same work is already in progress
                return false;
        }

        // no task associated with the ImageView, or an existing task was cancelled
        return true;
    }

    /**
     * Retrieves the BitmapAsyncTask object associated with the specified ImageView.
     * @param imageView The ImageView with associated BitmapAsyncTask.
     * @return A BitmapAsyncTask, null if no such object exists in the ImageView.
     */
    private static BitmapAsyncTask bitmapAsyncTask(ImageView imageView) {
        if (imageView != null) {
            final Drawable drawable = imageView.getDrawable();

            if (drawable instanceof AsyncDrawable) {
                final AsyncDrawable asyncDrawable = (AsyncDrawable)drawable;
                return asyncDrawable.getBitmapAsyncTask();
            }
        }

        return null;
    }
    //endregion

}
