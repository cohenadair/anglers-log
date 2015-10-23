package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.util.Log;
import android.util.LruCache;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * A utility class that manages both a disk and memory Bitmap cache.
 *
 * Created by Cohen Adair on 2015-10-21.
 */
public class PhotoCache {

    private static final String TAG = "PhotoCache";
    private static final String DISK_PREFIX = "IMG";
    private static final int PHOTO_QUALITY = 70;

    private Context mContext;
    private int mDiskCacheSize;

    /**
     * Used to prevent thread locking when interacting with the disk cache.
     */
    private boolean mDiskCacheStarting = true;
    private final Object mDiskCacheLock = new Object();

    private BitmapDiskCache mDiskCache;
    private LruCache<String, Bitmap> mMemoryCache;

    public PhotoCache(Context context, int diskSize, double memorySizePercent, String subDir) {
        mContext = context;
        mDiskCacheSize = diskSize;

        // initialize memory cache
        if (mMemoryCache == null) {
            int maxMemory = (int) (Runtime.getRuntime().maxMemory() / 1024);
            int cacheSize = (int)(maxMemory * memorySizePercent);

            mMemoryCache = new LruCache<String, Bitmap>(cacheSize) {
                @Override
                protected int sizeOf(String key, Bitmap bitmap) {
                    // the cache size will be measured in kilobytes rather than number of items
                    return bitmap.getByteCount() / 1024;
                }
            };
        }

        // initialize disk cache
        new DiskTask().execute(diskDirectory(subDir));
    }

    public void addBitmap(String path, int size, Bitmap bitmap) {
        String key = key(path, size);

        // add to memory cache
        if (bitmapFromMemory(path, size) == null)
            mMemoryCache.put(key, bitmap);

        // add to disk cache
        synchronized (mDiskCacheLock) {
            if (mDiskCache != null && mDiskCache.get(key) == null)
                mDiskCache.put(key, bitmap);
        }
    }

    public Bitmap bitmapFromMemory(String path, int size) {
        return mMemoryCache.get(key(path, size));
    }

    @Nullable
    public Bitmap bitmapFromDisk(String path, int size) {
        synchronized (mDiskCacheLock) {
            while (mDiskCacheStarting) {
                try {
                    mDiskCacheLock.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            if (mDiskCache != null)
                return mDiskCache.get(key(path, size));
        }

        return null;
    }

    /**
     * Saves the specified bitmap to the specified File object.
     *
     * @param bitmap The Bitmap object to save.
     * @param file The File object to be written to.
     * @return True if the bitmap was saved; false otherwise.
     */
    public static boolean savePhoto(Bitmap bitmap, File file) {
        FileOutputStream out = null;

        try {
            out = new FileOutputStream(file);
            return bitmap.compress(Bitmap.CompressFormat.JPEG, PHOTO_QUALITY, out);
        } catch (FileNotFoundException e) {
            Log.e(TAG, "File not found: " + file.getPath());
            e.printStackTrace();
        } finally {
            try {
                if (out != null)
                    out.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return false;
    }

    /**
     * Cleans the disk cache, keeping the files associated with the specified keys.
     *
     * @param keysToKeep An array of keys to keep.
     */
    public void cleanDisk(ArrayList<String> keysToKeep) {
        if (mDiskCache != null)
            mDiskCache.clean(keysToKeep);
    }

    /**
     * Completely clears the disk cache.
     */
    public void clearDisk() {
        mDiskCache.clear();
    }

    /**
     * Provides a unique cache key for different bitmap sizes.
     *
     * @param path The path of the bitmap to be cached.
     * @param size The size of the bitmap.
     * @return A String representing the key to be used in the cache.
     */
    private String key(String path, int size) {
        String name = path.substring(path.lastIndexOf("/") + 1);
        return DISK_PREFIX + size + "_" + name;
    }

    /**
     * Creates a unique subdirectory of this application's cache directory. Tries to use external
     * storage first, then falls back on internal storage.
     *
     * @param subDir The unique subdirectory name.
     * @return A File object representing the new cache directory.
     */
    private File diskDirectory(String subDir) {
        boolean useExternal = Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) || !Environment.isExternalStorageRemovable();
        String cachePath;

        if (useExternal && mContext.getExternalCacheDir() != null)
            cachePath = mContext.getExternalCacheDir().getPath();
        else
            cachePath = mContext.getCacheDir().getPath();

        return new File(cachePath + File.separator + subDir);
    }

    private class DiskTask extends AsyncTask<File, Void, Void> {
        @Override
        protected Void doInBackground(File... params) {
            synchronized (mDiskCacheLock) {
                File cacheDir = params[0];
                mDiskCache = openBitmapDiskCache(cacheDir, mDiskCacheSize);
                mDiskCacheStarting = false; // initializing finished
                mDiskCacheLock.notifyAll(); // wake any waiting threads
            }

            return null;
        }
    }

    //region BitmapDiskCache Class
    /**
     * Used to instantiate this instance. Makes sure the specified directory is a directory and
     * that it is writable.
     *
     * @param cacheDir The directory to save this cache.
     * @param maxByteSize The maximum size of this cache.
     * @return A DiskLruCache object if the specified directory is valid, null otherwise.
     */
    @Nullable
    public BitmapDiskCache openBitmapDiskCache(File cacheDir, long maxByteSize) {
        if (!cacheDir.exists())
            if (cacheDir.mkdir())
                Log.i(TAG, "Created cache directory.");

        if (cacheDir.isDirectory() && cacheDir.canWrite())
            return new BitmapDiskCache(cacheDir, maxByteSize);

        return null;
    }

    /**
     * A simple disk cache implementation for Bitmaps. Code derived from <a href="https://code.google.com/p/android/issues/detail?id=29400">here</a>.
     */
    public class BitmapDiskCache {
        private static final int INITIAL_CAPACITY = 32;
        private static final float LOAD_FACTOR = 0.75f;

        private final File mCacheDir;
        private int mCacheByteSize = 0;
        private long mMaxCacheByteSize;

        private final Map<String, String> mLinkedHashMap =
                Collections.synchronizedMap(new LinkedHashMap<String, String>(INITIAL_CAPACITY, LOAD_FACTOR, true));

        public BitmapDiskCache(File cacheDir, long maxByteSize) {
            mCacheDir = cacheDir;
            mMaxCacheByteSize = maxByteSize;
        }

        /**
         * Adds a Bitmap object to the disk cache.
         *
         * @param key A unique identifier for the bitmap.
         * @param data The Bitmap object to store.
         */
        public void put(String key, Bitmap data) {
            synchronized (mLinkedHashMap) {
                if (mLinkedHashMap.get(key) == null) {
                    String file = filePath(key);

                    if (savePhoto(data, new File(file))) {
                        mLinkedHashMap.put(key, file);
                        mCacheByteSize += new File(file).length();
                        flush();
                    }
                }
            }
        }

        /**
         * Retrieves the bitmap with the specified key.
         *
         * @param key The key to get.
         * @return A Bitmap object with the associated key, null if one doesn't exist.
         */
        public Bitmap get(String key) {
            synchronized (mLinkedHashMap) {
                String file = mLinkedHashMap.get(key);

                if (file != null)
                    return BitmapFactory.decodeFile(file);

                return null;
            }
        }

        /**
         * Flush the cache, removing oldest entries if the total size is over the specified cache size.
         * Note that this isn't keeping track of stale files in the cache directory that aren't in the
         * HashMap. The {@link #clean} method is used to remove unused files.
         */
        private void flush() {
            Map.Entry<String, String> eldestEntry;

            File eldestFile;
            long eldestFileSize = 0;

            while (mCacheByteSize > mMaxCacheByteSize) {
                eldestEntry = mLinkedHashMap.entrySet().iterator().next();
                eldestFile = new File(eldestEntry.getValue());
                mLinkedHashMap.remove(eldestEntry.getKey());

                if (eldestFile.delete()) {
                    mCacheByteSize -= eldestFileSize;
                    Log.i(TAG, "Flushed cache file: " + eldestFile + ", " + eldestFileSize);
                }
            }
        }

        /**
         * Removes all disk cache entries from the given directory.
         */
        public void clear() {
            deleteFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.startsWith(DISK_PREFIX);
                }
            });
        }

        /**
         * Removes any files that aren't in the specified Strings.
         * @param keysToKeep An array of substrings of the keys to keep.
         */
        public void clean(final ArrayList<String> keysToKeep) {
            deleteFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    for (String str : keysToKeep)
                        if (name.contains(str))
                            return true;

                    return keysToKeep.size() <= 0;
                }
            });
        }

        /**
         * Deletes all files in the cache directory matched by the specified FilenameFilter.
         * @param filter The filter used to match files.
         */
        private void deleteFiles(FilenameFilter filter) {
            int numDeleted = 0;

            File[] files = mCacheDir.listFiles(filter);
            for (File file : files)
                numDeleted += file.delete() ? 1 : 0;

            Log.i(TAG, "Deleted " + numDeleted + " cached photos.");
        }

        /**
         * Gets a file path for the specified key.
         *
         * @param key The key used to create the file path.
         * @return A String representing the file path.
         */
        public String filePath(String key) {
            return mCacheDir.getAbsolutePath() + File.separator + key;
        }
    }
    //endregion
}