package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

import de.hdodenhof.circleimageview.CircleImageView;

/**
 * An image scrolling view. This differs from a ViewPager in that this is a series of ImageView
 * objects embedded in a ScrollView.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class ImageScrollView extends LinearLayout {

    private RelativeLayout mContainer;
    private HorizontalScrollView mScrollView;
    private LinearLayout mPhotosWrapper;
    private InteractionListener mInteractionListener;

    public float mScrollSize;

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
        mScrollView = (HorizontalScrollView)view.findViewById(R.id.scroll_view);
        mPhotosWrapper = (LinearLayout)view.findViewById(R.id.photos_wrapper);
    }

    public void setInteractionListener(InteractionListener interactionListener) {
        mInteractionListener = interactionListener;
    }

    public void setImages(ArrayList<String> imagePaths) {
        if (imagePaths == null || imagePaths.size() <= 0) {
            Utils.toggleVisibility(mContainer, false);
            return;
        }

        Utils.toggleVisibility(mContainer, true);
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

        // used to correctly center the scroll view
        mScrollSize += size + getResources().getDimensionPixelOffset(R.dimen.margin_default);
    }

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
