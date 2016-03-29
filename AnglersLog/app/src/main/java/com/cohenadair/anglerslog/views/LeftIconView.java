package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.ViewUtils;

/**
 * An abstract class that includes manipulation methods for views with a left icon.
 * @author Cohen Adair
 */
public abstract class LeftIconView extends LinearLayout {

    private ImageView mIconImageView;

    public LeftIconView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    /**
     * Must be called by subclasses that wish to utilize the left icon.
     * @param resId The layout id to be inflated.
     */
    protected void init(int resId, AttributeSet attrs) {
        inflate(getContext(), resId, this);

        mIconImageView = (ImageView)findViewById(R.id.icon_image_view);

        if (attrs == null)
            return;

        TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.LeftIconView, 0, 0);

        try {
            setIconResource(arr.getResourceId(R.styleable.LeftIconView_iconResource, -1));
        } finally {
            arr.recycle(); // required after using TypedArray
        }
    }

    public ImageView getIconImageView() {
        return mIconImageView;
    }

    public void setIconResource(int resId) {
        if (resId == -1) {
            ViewUtils.setVisibility(mIconImageView, false);
            return;
        }

        mIconImageView.setImageResource(resId);
        ViewUtils.setVisibility(mIconImageView, true);
    }
}
