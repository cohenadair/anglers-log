package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A SelectionView is a view with a title and subtitle.
 * Created by Cohen Adair on 2015-09-30.
 */
public class SelectionView extends LinearLayout {

    private TextView mTitle;
    private TextView mSubtitle;

    public SelectionView(Context context) {
        this(context, null);
        init(null);
    }

    public SelectionView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_selection, this);

        mTitle = (TextView)findViewById(R.id.title_text_view);
        mSubtitle = (TextView)findViewById(R.id.subtitle_text_view);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.SelectionView, 0, 0);
            try {
                mTitle.setText(arr.getString(R.styleable.SelectionView_titleText));
                mSubtitle.setText(arr.getString(R.styleable.SelectionView_subtitleText));
                mSubtitle.setHint(arr.getString(R.styleable.SelectionView_subtitleHint));
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    //region Getters & Setters
    public String getTitle() {
        return mTitle.getText().toString();
    }

    public void setTitle(String title) {
        mTitle.setText(title);
    }

    public String getSubtitle() {
        return mSubtitle.getText().toString();
    }

    public void setSubtitle(String subtitle) {
        mSubtitle.setText(subtitle);
    }
    //endregion
}
