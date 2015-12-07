package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A FishingSpotView is a view that displays a single Fishing Spot in the view Location fragment.
 * Created by Cohen Adair on 2015-12-06.
 */
public class FishingSpotView extends LinearLayout {

    private TextView mTitle;
    private TextView mSubtitle;
    private ImageButton mRemoveButton;
    private LinearLayout mContentLayout;

    public FishingSpotView(Context context) {
        this(context, null);
        init(null);
    }

    public FishingSpotView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_fishing_spot, this);

        mTitle = (TextView)findViewById(R.id.title_text_view);
        mSubtitle = (TextView)findViewById(R.id.subtitle_text_view);
        mRemoveButton = (ImageButton)findViewById(R.id.remove_button);
        mContentLayout = (LinearLayout)findViewById(R.id.content_layout);
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

    public void setOnClickRemoveButton(OnClickListener listener) {
        mRemoveButton.setOnClickListener(listener);
    }

    public void setOnClickContent(OnClickListener listener) {
        mContentLayout.setOnClickListener(listener);
    }
}
