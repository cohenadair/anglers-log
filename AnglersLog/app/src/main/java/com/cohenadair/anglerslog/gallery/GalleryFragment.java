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
 * Created by Cohen Adair on 2016-02-01.
 */
public class GalleryFragment extends MasterFragment {

    private static final int SPACING = 2;
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

    }

    private void initGridView(View view) {
        GridView gridView = (GridView)view.findViewById(R.id.grid_view);
        gridView.setAdapter(new ImageAdapter(getContext(), mPhotos));
        gridView.setColumnWidth(getImageSize());
        gridView.setHorizontalSpacing(SPACING);
        gridView.setVerticalSpacing(SPACING);
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                startActivity(PhotoViewerActivity.getIntent(getContext(), mPhotos, position));
            }
        });
    }

    private int getImageSize() {
        int maxSize = (int)Utils.dpToPx(MAX_SIZE);
        int screenWidth = Utils.getScreenSize(getContext()).x;
        int size = screenWidth / 3 - SPACING;

        if (size > maxSize) {
            int perRow = screenWidth / maxSize;
            size = screenWidth / perRow - SPACING;
        }

        return size;
    }

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
            ImageView imageView;

            if (convertView == null) {
                imageView = new ImageView(mContext);
                imageView.setLayoutParams(new GridView.LayoutParams(getImageSize(), getImageSize()));
                imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            } else
                imageView = (ImageView)convertView;

            PhotoUtils.thumbnailToImageView(imageView, getFullPath(position), getImageSize(), R.drawable.no_catch_photo);
            return imageView;
        }

        private String getFullPath(int position) {
            return PhotoUtils.privatePhotoPath(mPhotos.get(position));
        }
    }
}
