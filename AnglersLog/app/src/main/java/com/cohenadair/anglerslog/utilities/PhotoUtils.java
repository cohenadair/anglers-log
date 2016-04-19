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
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.widget.ImageView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.exif.ExifIFD0Directory;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

/**
 * Any utility functions that have anything to do with photos/photo manipulation.
 * @author Cohen Adair
 */
public class PhotoUtils {

    private static Context mContext;
    private static PhotoCache mCache;

    private PhotoUtils() { }

    public static void init(Context context) {
        PhotoUtils.mContext = context;
        mCache = new PhotoCache(context, 1024 * 1024 * 10, 0.125, "bitmap_cache");
    }

    @NonNull
    public static Intent pickPhotoIntent(boolean allowMultiSelect) {
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);

        // multiple selection is only available on API level 18+
        if (Build.VERSION.SDK_INT >= 18)
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, allowMultiSelect);

        return Intent.createChooser(intent, mContext.getResources().getString(R.string.select_photo));
    }

    @NonNull
    public static Intent takePhotoIntent() {
        return new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    }

    /**
     * Scales the image at the specified path to the specified dimension. This method should be
     * executed away from the UI thread. Keeps aspect ratio.
     *
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

        options = scaledBitmapSampleSize(options.outWidth, options.outHeight, destWidth, destHeight);

        // read in and create the final bitmap
        return BitmapFactory.decodeFile(path, options);
    }

    /**
     * Scales the photo at the given Uri to the specified size. Keeps aspect ratio. The longest
     * dimension of the photo will be scaled down to `longestDestLength`.
     *
     * @param uri The Uri of the photo to be scaled.
     * @param longestDestLength The longest side length for the destination photo, in pixels.
     * @return A scaled Bitmap version of the photo at the specified Uri, or null if the scale
     * failed.
     */
    @Nullable
    private static Bitmap scaledBitmap(Uri uri, int longestDestLength) {
        InputStream in = null;

        // create InputStream from Uri
        try {
            in = mContext.getContentResolver().openInputStream(uri);

            // read in the dimensions of the image on disk
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeStream(in, null, options);

            if (in != null)
                in.close();

            options = scaledBitmapSampleSize(options.outWidth, options.outHeight, longestDestLength, longestDestLength);

            // reset InputStream as it cannot be used more than once
            in = mContext.getContentResolver().openInputStream(uri);

            // read in and create the final bitmap
            return BitmapFactory.decodeStream(in, null, options);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (in != null)
                    in.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return null;
    }

    /**
     * Gets the scale factor to scale the source size to the destination size.
     *
     * @param srcWidth Original width, in pixels.
     * @param srcHeight Original height, in pixels.
     * @param destWidth New width, in pixels.
     * @param destHeight New height, in pixels.
     * @return A BitmapFactory.Options object with the `inSampleSize` field set.
     */
    private static BitmapFactory.Options scaledBitmapSampleSize(int srcWidth, int srcHeight, int destWidth, int destHeight) {
        // figure out how much to scale by
        int inSampleSize = 1;
        if (srcHeight > destHeight || srcWidth > destWidth)
            if (srcWidth < srcHeight)
                inSampleSize = (int)Math.ceil((double) srcHeight / (double) destHeight);
            else
                inSampleSize = (int)Math.ceil((double) srcWidth / (double) destWidth);

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inSampleSize = inSampleSize;

        return options;
    }

    /**
     * Takes a photo at a given path, scales it, generates a thumbnail of specified size, and
     * inserts into the given ImageView. This entire process is done asynchronously using
     * {@link com.cohenadair.anglerslog.utilities.PhotoUtils.BitmapAsyncTask}.
     *
     * @param imageView The ImageView to display the thumbnail.
     * @param path The path to the photo.
     * @param size The size of the ImageView, in pixels.
     */
    public static void thumbnailToImageView(ImageView imageView, String path, int size, int placeHolderResId) {
        Bitmap placeHolder = BitmapFactory.decodeResource(mContext.getResources(), placeHolderResId);
        Bitmap fromCache = mCache.bitmapFromMemory(path, size);

        if (fromCache != null)
            imageView.setImageBitmap(fromCache);
        else if (cancelPotentialWork(path, imageView)) {
            final BitmapAsyncTask task = new BitmapAsyncTask(imageView, size, size, true);
            final AsyncDrawable asyncDrawable = new AsyncDrawable(mContext.getResources(), placeHolder, task);
            imageView.setImageDrawable(asyncDrawable);
            task.execute(path);
        }
    }

    /**
     * Takes the photo at a specified path and puts it into the specified ImageView. This method
     * *does not* cache the scaled Bitmap.
     *
     * @param imageView The ImageView to display.
     * @param path The path to the photo.
     * @param width The width of the ImageView.
     * @param height The height of the ImageView.
     */
    public static void photoToImageView(ImageView imageView, String path, int width, int height) {
        Bitmap scaledBitmap = scaledBitmap(path, width, height);
        scaledBitmap = ThumbnailUtils.extractThumbnail(scaledBitmap, width, height);
        imageView.setImageBitmap(scaledBitmap);
    }

    /**
     * Rotates the specified bitmap to the correct orientation. The specified Uri is used to get the
     * exif information (i.e. orientation) so the Bitmap can be properly rotated. Note that this library
     * requires the following two libraries:
     * 1. <a href="https://code.google.com/p/metadata-extractor/downloads/list">metadata-extractor-2.6.4</a>
     * 2. <a href="https://github.com/drewfarris/metadata-extractor/tree/master/Libraries">xmpcore-5.1.2.jar</a>
     *
     * @param uri The Uri to the photo file.
     * @param bmp The Bitmap representative of the photo file.
     * @return A correctly rotated Bitmap.
     */
    private static Bitmap fixOrientation(Uri uri, Bitmap bmp) {
        BufferedInputStream bufferStream = null;
        Metadata metadata;

        try {
            InputStream inputStream = mContext.getContentResolver().openInputStream(uri);
            if (inputStream != null)
                bufferStream = new BufferedInputStream(inputStream);
        } catch (IOException e) {
            e.printStackTrace();
            return bmp;
        }

        if (bufferStream != null) {
            try {
                metadata = ImageMetadataReader.readMetadata(bufferStream);
            } catch (Exception e) {
                e.printStackTrace();
                return bmp;
            }

            if (metadata != null) {
                int orientation = 0;
                ExifIFD0Directory exifIFD0Directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);

                if (exifIFD0Directory != null && exifIFD0Directory.containsTag(ExifIFD0Directory.TAG_ORIENTATION))
                    try {
                        orientation = exifIFD0Directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
                    } catch (MetadataException e){
                        e.printStackTrace();
                        return bmp;
                    }

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
            }
        }

        return bmp;
    }

    /**
     * Rotates the specified bitmap by the specified degrees.
     *
     * @param bmp The Bitmap to rotate.
     * @param degrees How much to rotate the Bitmap.
     * @return A rotated Bitmap.
     */
    private static Bitmap rotateBitmap(Bitmap bmp, int degrees) {
        Matrix matrix = new Matrix();
        matrix.postRotate(degrees);
        return Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(), matrix, true);
    }

    /**
     * Gets the photo storage directory for this application.
     *
     * @return A File object of the storage directory.
     */
    public static File privatePhotoDirectory() {
        return mContext.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
    }

    /**
     * Gets a pointer to a file where a new photo can be saved. This location is private to this
     * application.
     *
     * @param fileName The name of the new photo.
     * @return A File object pointing to the photo's storage location.
     */
    @Nullable
    public static File privatePhotoFile(String fileName) {
        File externalFilesDir = privatePhotoDirectory();

        if (externalFilesDir == null)
            return null;

        return new File(externalFilesDir, fileName);
    }

    /**
     * Gets the full path to the specified file name.
     *
     * @param fileName The name of the file to get.
     * @return A String of the file's path.
     */
    public static String privatePhotoPath(String fileName) {
        File f = privatePhotoFile(fileName);
        return (f == null) ? null : f.getPath();
    }

    /**
     * Gets a {@link Uri} of the given file name.
     *
     * @param fileName The file's name.
     * @return A {@link Uri} of the given file name.
     */
    public static Uri privatePhotoUri(String fileName) {
        return Uri.fromFile(privatePhotoFile(fileName));
    }

    /**
     * Gets a pointer to a file location in the devices public storage.
     *
     * @param fileName The name of the file to to be created.
     * @return A File object if the directory exists, null otherwise.
     */
    @Nullable
    public static File publicPhotoFile(String fileName) {
        String photosPath = Environment.DIRECTORY_PICTURES + mContext.getResources().getString(R.string.app_photos_dir);
        File publicDirectory = Environment.getExternalStoragePublicDirectory(photosPath);

        if (publicDirectory.mkdirs() || publicDirectory.isDirectory())
            return new File(publicDirectory, fileName);

        return null;
    }

    /**
     * Copies a photo to a new location and scales it down to `R.dimen.max_photo_size` pixels.
     *
     * @param srcUri The source Uri of the photo.
     * @param destFile The destination file the Bitmap will be written to.
     */
    public static void copyAndResizePhoto(Uri srcUri, File destFile) {
        if (destFile != null) {
            int longestSideLength = mContext.getResources().getInteger(R.integer.max_photo_size);
            Bitmap scaledBitmap = fixOrientation(srcUri, scaledBitmap(srcUri, longestSideLength));
            PhotoCache.savePhoto(scaledBitmap, destFile);
        }
    }

    /**
     * Saves an image resource to the device's storage.
     * @param resId The resource id of the file to save.
     * @param fileName The name of the file.
     */
    public static void saveImageResource(int resId, String fileName) {
        File destFile = privatePhotoFile(fileName);
        if (destFile == null)
            return;

        Bitmap bitmap = BitmapFactory.decodeResource(mContext.getResources(), resId);

        try {
            FileOutputStream out = new FileOutputStream(destFile);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
            out.flush();
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Cross references the photo files in private storage with the names of photos used throughout
     * the application and deletes photos that aren't used. This method should never be called on
     * the UI thread. Use {@link #cleanPhotosAsync()} instead.
     */
    public static void cleanPhotos() {
        File photosDir = privatePhotoDirectory();

        if (photosDir != null && photosDir.isDirectory()) {
            File[] photoFiles = photosDir.listFiles();

            for (int i = photoFiles.length - 1; i >= 0; i--) {

                // check all Catch objects for the current File
                for (UserDefineObject aCatch : Logbook.getCatches())
                    if (((Catch)aCatch).getPhotos().indexOf(photoFiles[i].getName()) >= 0)
                        break;

                // check all Bait objects for the current file
                for (UserDefineObject aBait : Logbook.getBaits())
                    if (((Bait)aBait).getPhotos().indexOf(photoFiles[i].getName()) >= 0)
                        break;
            }
        }
    }

    /**
     * Similar to {@link #cleanPhotos()} except it cleans the disk cache. This method should never
     * be called on the UI thread. Use {@link #cleanPhotosAsync()} instead.
     */
    private static void cleanCache() {
        ArrayList<String> photoNames = new ArrayList<>();
        ArrayList<UserDefineObject> catches = Logbook.getCatches();

        for (UserDefineObject aCatch : catches)
            photoNames.addAll(((Catch)aCatch).getPhotos());

        mCache.clean(photoNames);
    }

    /**
     * Cleans up photo files in another thread.
     * @see #cleanPhotos()
     */
    public static void cleanPhotosAsync() {
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                cleanPhotos();
                cleanCache();
            }
        });
        thread.start();
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
            Bitmap scaledBitmap = mCache.bitmapFromDisk(mPath, mWidth);

            // process image if it isn't cached
            if (scaledBitmap == null) {
                scaledBitmap = scaledBitmap(mPath, mWidth, mHeight);

                // get thumbnail if needed
                if (mGenerateThumb) {
                    int size = (mWidth > mHeight) ? mHeight : mWidth; // get the smaller of the width/height
                    scaledBitmap = ThumbnailUtils.extractThumbnail(scaledBitmap, size, size);
                }
            }

            // cache bitmap to use later
            mCache.addBitmap(mPath, mWidth, scaledBitmap);

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
     *
     * @param imageView The ImageView with associated BitmapAsyncTask.
     * @return A BitmapAsyncTask associated with the ImageView, or null if no such object exists.
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
