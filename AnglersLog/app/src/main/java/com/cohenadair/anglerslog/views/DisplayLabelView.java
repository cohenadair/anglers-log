package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A simple view that shows a TextView and ImageView icon.
 * @author Cohen Adair
 */
public class DisplayLabelView extends LeftIconView {

    private TextView mLabelTextView;

    public DisplayLabelView(Context context) {
        this(context, null);
    }

    public DisplayLabelView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public void init(AttributeSet attrs) {
        init(R.layout.view_display_label, attrs);

        mLabelTextView = (TextView)findViewById(R.id.text_view);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.DisplayLabelView, 0, 0);

            try {
                setLabel(arr.getString(R.styleable.DisplayLabelView_labelText));
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    public void setLabel(int resId) {
        mLabelTextView.setText(resId);
    }

    public void setLabel(String label) {
        mLabelTextView.setText(label);
    }
}
