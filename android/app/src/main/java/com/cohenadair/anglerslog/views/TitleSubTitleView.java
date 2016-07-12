package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.ViewUtils;

/**
 * A TitleSubTitleView is a view that neatly displays a title and subtitle text vertically.
 * @author Cohen Adair
 */
public class TitleSubTitleView extends LinearLayout {

    private TextView mTitle;
    private TextView mSubtitle;
    private TextView mSubSubtitle;

    public TitleSubTitleView(Context context) {
        super(context);
        init(null);
    }

    public TitleSubTitleView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_title_subtitle, this);

        mTitle = (TextView)findViewById(R.id.title_text_view);
        mSubtitle = (TextView)findViewById(R.id.subtitle_text_view);
        mSubSubtitle = (TextView)findViewById(R.id.subsubtitle_text_view);
        toggleSubSubtitleViewVisibility();

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.TitleSubTitleView, 0, 0);
            try {
                mTitle.setText(arr.getString(R.styleable.TitleSubTitleView_titleText));
                mSubtitle.setText(arr.getString(R.styleable.TitleSubTitleView_subtitleText));
                mSubtitle.setHint(arr.getString(R.styleable.TitleSubTitleView_subtitleHint));

                mSubSubtitle.setText(arr.getString(R.styleable.TitleSubTitleView_subsubtitleText));
                toggleSubSubtitleViewVisibility();

                int styleId = arr.getResourceId(R.styleable.TitleSubTitleView_titleStyle, -1);
                if (styleId != -1)
                    ViewUtils.setTextAppearance(getContext(), mTitle, styleId);

                styleId = arr.getResourceId(R.styleable.TitleSubTitleView_subtitleStyle, -1);
                if (styleId != -1) {
                    ViewUtils.setTextAppearance(getContext(), mSubtitle, styleId);
                    ViewUtils.setTextAppearance(getContext(), mSubSubtitle, styleId);
                }
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    public void setTitle(String title) {
        mTitle.setText(title);
    }

    public String getTitle() {
        return mTitle.getText().toString();
    }

    public void setSubtitle(String subtitle) {
        mSubtitle.setText(subtitle);
    }

    public String getSubtitle() {
        return mSubtitle.getText().toString();
    }

    public void setSubSubtitle(String subtitle) {
        mSubSubtitle.setText(subtitle);
        toggleSubSubtitleViewVisibility();
    }

    public void hideSubtitle() {
        mSubtitle.setVisibility(View.GONE);
    }

    public void setTitleStyle(int resId) {
        ViewUtils.setTextAppearance(getContext(), mTitle, resId);
    }

    public void setSubtitleStyle(int resId) {
        ViewUtils.setTextAppearance(getContext(), mSubtitle, resId);
    }

    private void toggleSubSubtitleViewVisibility() {
        ViewUtils.setVisibility(mSubSubtitle, !mSubSubtitle.getText().toString().isEmpty());
    }
}
