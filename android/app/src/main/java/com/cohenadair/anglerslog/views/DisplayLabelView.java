package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.ViewUtils;

/**
 * A simple view that shows a TextView and ImageView icon.
 * @author Cohen Adair
 */
public class DisplayLabelView extends LeftIconView {

    private LinearLayout mContainer;
    private TextView mLabelTextView;
    private TextView mDetailTextView;

    public DisplayLabelView(Context context) {
        this(context, null);
    }

    public DisplayLabelView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        init(R.layout.view_display_label, attrs);

        mContainer = (LinearLayout)findViewById(R.id.display_label_container);
        mLabelTextView = (TextView)findViewById(R.id.text_view);
        mDetailTextView = (TextView)findViewById(R.id.detail_text_view);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.DisplayLabelView, 0, 0);

            try {
                setLabel(arr.getString(R.styleable.DisplayLabelView_labelText));
                setDetail(arr.getString(R.styleable.DisplayLabelView_detailText));
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    public void setDetail(String detail) {
        mDetailTextView.setText(detail);
    }

    public void setLabel(String label) {
        if (Utils.stringOrNull(label) == null) {
            ViewUtils.setVisibility(mLabelTextView, false);
            return;
        }

        mLabelTextView.setText(label);
        ViewUtils.setVisibility(mLabelTextView, true);
    }

    public void setOnClickListener(OnClickListener l) {
        mContainer.setOnClickListener(l);
    }
}
