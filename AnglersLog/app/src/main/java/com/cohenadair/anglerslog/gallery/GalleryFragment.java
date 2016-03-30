package com.cohenadair.anglerslog.gallery;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.MasterFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

/**
 * The GalleryFragment displays a gallery of the user's photos.
 * @author Cohen Adair
 */
public class GalleryFragment extends MasterFragment {

    // largest size of a gallery cell
    // this is used so tablets in landscape don't have massive thumbnail sizes
    private static final int MAX_SIZE = 150;

    private ArrayList<String> mPhotos;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setClearMenuOnCreate(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_gallery, container, false);

        mPhotos = Logbook.getAllCatchPhotos();
        initGridView(view);

        updateInterface();

        return view;
    }

    @Override
    public void updateInterface() {
        getRealActivity().setActionBarTitle(getRealActivity().getTitleName(mPhotos.size()));
    }

    private void initGridView(View view) {
        GridView gridView = (GridView)view.findViewById(R.id.grid_view);
        gridView.setAdapter(new ImageAdapter(getContext(), mPhotos));
        gridView.setColumnWidth(getImageSize());
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                startActivity(PhotoViewerActivity.getIntent(getContext(), mPhotos, position));
            }
        });
    }

    /**
     * Uses the screen size to calculate the size of each thumbnail so they are evenly
     * distributes across the screen.
     *
     * @return The size of each image, in pixels.
     */
    private int getImageSize() {
        int maxSize = (int)Utils.dpToPx(MAX_SIZE);
        int screenWidth = Utils.getScreenSize(getContext()).x;
        int size = screenWidth / 3;

        if (size > maxSize) {
            int perRow = (screenWidth / maxSize) + 1; // the +1 removes any remaining space
            size = screenWidth / perRow;
        }

        return size;
    }

    /**
     * Each item in this {@link BaseAdapter} subclass has a single {@link ImageView} that can be
     * clicked to open a full-sized version of the image.
     */
    public class ImageAdapter extends BaseAdapter {

        private Context mContext;
        private ArrayList<String> mPhotos;

        public ImageAdapter(Context context, ArrayList<String> photoNames) {
            mContext = context;
            mPhotos = photoNames;
        }

        @Override
        public int getCount() {
            return mPhotos.size();
        }

        @Override
        public Object getItem(int position) {
            return mPhotos.get(position);
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            final ImageView imageView;

            if (convertView == null) {
                imageView = new ImageView(mContext);
                imageView.setLayoutParams(new GridView.LayoutParams(getImageSize(), getImageSize()));
                imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            } else
                imageView = (ImageView)convertView;

            // update padding to give evenly distributed spacing
            int p = 5;

            if ((position + 1) % 3 == 0)
                imageView.setPadding(0, 0, 0, p * 2);
            else
                imageView.setPadding(0, 0, p, p);

            PhotoUtils.thumbnailToImageView(imageView, getFullPath(position), getImageSize(), R.drawable.placeholder_square);
            return imageView;
        }

        private String getFullPath(int position) {
            return PhotoUtils.privatePhotoPath(mPhotos.get(position));
        }
    }
}
