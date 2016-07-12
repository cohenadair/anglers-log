package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;

/**
 * A MoreDetailView is a view that displays a single a {@link TitleSubTitleView} with a clickable
 * "more info" button.
 *
 * @author Cohen Adair
 */
public class MoreDetailView extends LinearLayout {

    private TitleSubTitleView mTitleSubTitleView;
    private ImageButton mDetailButton;
    private LinearLayout mContainer;

    public MoreDetailView(Context context) {
        this(context, null);
        init(null);
    }

    public MoreDetailView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_more_detail, this);

        mTitleSubTitleView = (TitleSubTitleView)findViewById(R.id.title_subtitle_view);
        mTitleSubTitleView.init(attrs);

        mDetailButton = (ImageButton)findViewById(R.id.more_info_button);
        mContainer = (LinearLayout)findViewById(R.id.container);

        if (attrs == null)
            return;

        TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.MoreDetailView, 0, 0);
        try {
            int detailImageId = arr.getResourceId(R.styleable.MoreDetailView_detailIcon, -1);
            if (detailImageId != -1)
                setDetailButtonImage(detailImageId);
        } finally {
            arr.recycle(); // required after using TypedArray
        }
    }

    //region Getters & Setters
    public String getTitle() {
        return mTitleSubTitleView.getTitle();
    }

    public void setTitle(String title) {
        mTitleSubTitleView.setTitle(title);
    }

    public String getSubtitle() {
        return mTitleSubTitleView.getSubtitle();
    }

    public void setSubtitle(String subtitle) {
        mTitleSubTitleView.setSubtitle(subtitle);
    }
    //endregion

    public void setOnClickDetailButton(OnClickListener listener) {
        mDetailButton.setOnClickListener(listener);
    }

    public void setOnClickContent(OnClickListener listener) {
        mContainer.setOnClickListener(listener);
    }

    public void setDetailButtonImage(int resId) {
        mDetailButton.setImageResource(resId);
    }

    public void setTitleStyle(int resId) {
        mTitleSubTitleView.setTitleStyle(resId);
    }

    public void setSubtitleStyle(int resId) {
        mTitleSubTitleView.setSubtitleStyle(resId);
    }

    /**
     * Uses a LayoutParams to create spacing similar to the default margins.
     */
    public void useNoLeftSpacing() {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(
                0,
                getResources().getDimensionPixelSize(R.dimen.spacing_small),
                getResources().getDimensionPixelSize(R.dimen.margin_default),
                getResources().getDimensionPixelSize(R.dimen.spacing_small)
        );
        mContainer.setLayoutParams(params);
    }

    public void useDefaultStyle() {
        setTitleStyle(R.style.TextView_Small);
        setSubtitleStyle(R.style.TextView_SmallSubtitle);
    }
}
