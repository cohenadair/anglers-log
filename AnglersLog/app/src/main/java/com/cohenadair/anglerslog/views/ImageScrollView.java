package com.cohenadair.anglerslog.views;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

/**
 * An image scrolling view. This differs from a ViewPager in that this is a series of ImageView
 * objects embedded in a ScrollView.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class ImageScrollView extends LinearLayout {

    private LinearLayout mPhotosWrapper;
    private InteractionListener mInteractionListener;

    public interface InteractionListener {
        void onImageClick(int position);
    }

    public ImageScrollView(Context context) {
        this(context, null);
        init();
    }

    public ImageScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        View view = inflate(getContext(), R.layout.view_image_scroll, this);
        mPhotosWrapper = (LinearLayout)view.findViewById(R.id.photos_wrapper);
    }

    public void setInteractionListener(InteractionListener interactionListener) {
        mInteractionListener = interactionListener;
    }

    public void setImages(ArrayList<String> imagePaths) {
        mPhotosWrapper.removeAllViews();

        int size = Utils.getScreenSize((Activity)getContext()).x;

        // if in two-pane or there's more than one photo, show smaller thumbnails
        if (Utils.isTwoPane(getContext()) || imagePaths.size() > 1)
            size = getContext().getResources().getDimensionPixelSize(R.dimen.image_scroll_size);

        for (int i = 0; i < imagePaths.size(); i++)
            addImage(PhotoUtils.privatePhotoPath(imagePaths.get(i)), i, size);
    }

    public void addImage(String path, final int position, int size) {
        ImageView img = new ImageView(getContext());
        img.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mInteractionListener != null)
                    mInteractionListener.onImageClick(position);
            }
        });

        PhotoUtils.thumbnailToImageView(img, path, size, R.drawable.no_catch_photo);
        updateImageMargins();

        mPhotosWrapper.addView(img);
    }

    private void updateImageMargins() {
        for (int i = 0; i < mPhotosWrapper.getChildCount(); i++) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)mPhotosWrapper.getChildAt(i).getLayoutParams();
            params.setMargins(0, 0, getResources().getDimensionPixelSize(R.dimen.spacing_small_half), 0);
        }
    }
}
