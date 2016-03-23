package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.Button;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * A simple view used for user selection, such as selecting a
 * {@link com.cohenadair.anglerslog.model.user_defines.Species} or a date and time.  The view
 * includes an icon, and two customizable input buttons.
 *
 * This view could also be used as a simple label when the `custom:asLabel` property is set to true.
 *
 * @author Cohen Adair
 */
public class InputButtonView extends LeftIconView {

    private Button mPrimaryButton;
    private Button mSecondaryButton;

    public InputButtonView(Context context) {
        this(context, null);
    }

    public InputButtonView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public void init(AttributeSet attrs) {
        init(R.layout.view_input_button, attrs);

        mPrimaryButton = (Button)findViewById(R.id.primary_button);
        mSecondaryButton = (Button)findViewById(R.id.secondary_button);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.InputButtonView, 0, 0);

            try {
                // possibly use as label, not input
                setPrimaryButtonClickable(!arr.getBoolean(R.styleable.InputButtonView_asLabel, false));

                // primary text
                String primaryText = arr.getString(R.styleable.InputButtonView_primaryHint);
                mPrimaryButton.setHint(primaryText);

                // secondary button
                boolean showSecondary = arr.getBoolean(R.styleable.InputButtonView_showSecondary, false);
                Utils.toggleVisibility(mSecondaryButton, showSecondary);
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

    private void setPrimaryButtonClickable(boolean clickable) {
        mPrimaryButton.setClickable(clickable);
        if (!clickable)
            mPrimaryButton.setBackgroundResource(android.R.color.transparent);
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
}
