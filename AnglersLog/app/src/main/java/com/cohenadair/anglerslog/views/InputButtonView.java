package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * A simple view used for user selection, such as selecting a
 * {@link com.cohenadair.anglerslog.model.user_defines.Species} or a date and time.  The view
 * includes an icon, and two customizable input buttons.
 *
 * @author Cohen Adair
 */
public class InputButtonView extends LinearLayout {

    private Button mPrimaryButton;
    private Button mSecondaryButton;
    private ImageView mIconImageView;

    public InputButtonView(Context context) {
        super(context);
        init(null);
    }

    public InputButtonView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_input_button, this);

        mPrimaryButton = (Button)findViewById(R.id.primary_button);
        mSecondaryButton = (Button)findViewById(R.id.secondary_button);
        mIconImageView = (ImageView)findViewById(R.id.icon_image_view);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.InputButtonView, 0, 0);

            try {
                // primary text
                String primaryText = arr.getString(R.styleable.InputButtonView_primaryHint);
                mPrimaryButton.setHint(primaryText);

                // secondary button
                boolean showSecondary = arr.getBoolean(R.styleable.InputButtonView_showSecondary, false);
                Utils.toggleVisibility(mSecondaryButton, showSecondary);

                // icon
                int iconResId = arr.getResourceId(R.styleable.InputButtonView_iconResource, -1);
                setIconResource(iconResId);
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    public void setOnClickPrimaryButton(OnClickListener l) {
        mPrimaryButton.setOnClickListener(l);
    }

    public void setOnClickSecondaryButton(OnClickListener l) {
        mSecondaryButton.setOnClickListener(l);
    }

    public void setPrimaryButtonText(String text) {
        mPrimaryButton.setText(text);
    }

    public void setPrimaryButtonHint(int resId) {
        mPrimaryButton.setHint(resId);
    }

    public void setSecondaryButtonText(String text) {
        mSecondaryButton.setText(text);
    }

    public void setIconResource(int resId) {
        Utils.setImageOrHide(mIconImageView, resId);
    }
}
