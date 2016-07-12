package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.ViewUtils;

import java.util.ArrayList;

import de.hdodenhof.circleimageview.CircleImageView;

/**
 * An image scrolling view. This differs from a ViewPager in that this is a series of ImageView
 * objects embedded in a ScrollView and is normally used as a small part of a Fragment, rather
 * than full screen interaction.
 *
 * @author Cohen Adair
 */
public class ImageScrollView extends LinearLayout {

    private RelativeLayout mContainer;
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

        mContainer = (RelativeLayout)view.findViewById(R.id.image_scroll_container);
        mPhotosWrapper = (LinearLayout)view.findViewById(R.id.photos_wrapper);
    }

    public void setInteractionListener(InteractionListener interactionListener) {
        mInteractionListener = interactionListener;
    }

    public void setImages(ArrayList<String> imagePaths) {
        if (imagePaths == null || imagePaths.size() <= 0) {
            ViewUtils.setVisibility(mContainer, false);
            return;
        }

        ViewUtils.setVisibility(mContainer, true);
        mPhotosWrapper.removeAllViews();

        int size = getResources().getDimensionPixelSize(R.dimen.image_scroll_size);

        for (int i = 0; i < imagePaths.size(); i++)
            addImage(PhotoUtils.privatePhotoPath(imagePaths.get(i)), i, size);

        updateImageMargins();
    }

    public void addImage(String path, final int position, int size) {
        CircleImageView img = new CircleImageView(getContext());
        img.setLayoutParams(new LayoutParams(size, size));
        img.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mInteractionListener != null)
                    mInteractionListener.onImageClick(position);
            }
        });

        PhotoUtils.thumbnailToImageView(img, path, size, R.drawable.placeholder_square);
        mPhotosWrapper.addView(img);
    }

    /**
     * Ensures there is even spacing between all images.
     */
    private void updateImageMargins() {
        for (int i = 0; i < mPhotosWrapper.getChildCount(); i++) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)mPhotosWrapper.getChildAt(i).getLayoutParams();
            params.setMargins(
                    getResources().getDimensionPixelSize(R.dimen.margin_half),
                    0,
                    getResources().getDimensionPixelSize(R.dimen.margin_half),
                    0
            );
        }
    }
}
