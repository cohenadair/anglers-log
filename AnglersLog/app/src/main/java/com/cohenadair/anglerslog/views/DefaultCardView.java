package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.graphics.Point;
import android.util.AttributeSet;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.ViewUtils;

import java.util.ArrayList;

/**
 * A DefaultCardView is a view that displays a default styled
 * {@link android.support.v7.widget.CardView}.
 *
 * @author Cohen Adair
 */
public class DefaultCardView extends LinearLayout {

    private ImageView mBannerImageView;
    private ImageView mIconImageView;
    private TextView mTitleView;
    private LinearLayout mContentContainer;
    private Button mShowMoreButton;

    public DefaultCardView(Context context) {
        this(context, null);
        init();
    }

    public DefaultCardView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.view_card_default, this);

        mBannerImageView = (ImageView)findViewById(R.id.banner_image_view);
        ViewUtils.setVisibility(mBannerImageView, false);

        mIconImageView = (ImageView)findViewById(R.id.icon_image_view);
        ViewUtils.setVisibility(mIconImageView, false);

        mTitleView = (TextView)findViewById(R.id.title_text_view);
        mContentContainer = (LinearLayout)findViewById(R.id.content_container);
        mShowMoreButton = (Button)findViewById(R.id.show_more_button);
    }

    /**
     * Initializes this view with a list of {@link PropertyDetailView}s based on the given content.
     *
     * @param title The title of the card.
     * @param content An array of property-detail values.
     * @param onClickButton The listener for the "show more" button.
     */
    public void initWithList(String title, ArrayList<Stats.Quantity> content, OnClickListener onClickButton) {
        setTitle(title);
        setOnClickShowMoreButton(onClickButton);
        updateContent(content);
    }

    public void initWithDisplayLabel(String cardTitle, String detailText, String labelText, OnClickListener onClickDetail, OnClickListener onClickCard) {
        setTitle(cardTitle);
        setOnClickShowMoreButton(onClickCard);

        DisplayLabelView view = new DisplayLabelView(getContext());
        view.setDetail(detailText);
        view.setLabel(labelText);
        view.setOnClickListener(onClickDetail);
        view.setIconResource(-1);

        // required to offset the default padding in view_display_label.xml
        view.setPadding(
                0,
                getResources().getDimensionPixelOffset(R.dimen.margin_default_negative),
                0,
                getResources().getDimensionPixelOffset(R.dimen.margin_default_negative)
        );

        mContentContainer.addView(view);
    }

    public void setBannerImage(String path) {
        if (path == null)
            return;

        Point screenSize = Utils.getScreenSize(getContext());
        int w = screenSize.x < screenSize.y ? screenSize.x : getResources().getDimensionPixelOffset(R.dimen.stats_column_width); // take the smaller of the width/height for tablet support
        int h = (int)(w * 9f / 16f); // keep 16:9 aspect ratio as per Material Design Guidelines

        mBannerImageView.getLayoutParams().width = w;
        mBannerImageView.getLayoutParams().height = h;
        mBannerImageView.requestLayout();

        PhotoUtils.photoToImageView(mBannerImageView, path, w, h);
        ViewUtils.setVisibility(mBannerImageView, true);
    }

    public void setIconImage(int resId) {
        mIconImageView.setImageResource(resId);
        ViewUtils.setVisibility(mIconImageView, true);
    }

    public void setTitle(String title) {
        mTitleView.setText(title);
    }

    public void setOnClickShowMoreButton(OnClickListener listener) {
        mShowMoreButton.setOnClickListener(listener);
    }

    /**
     * Updates the content view with a list of {@link PropertyDetailView}s.
     * @param content An array of property-detail values.
     */
    private void updateContent(ArrayList<Stats.Quantity> content) {
        ViewUtils.setVisibility(this, content.size() > 0);

        if (content.size() <= 0)
            return;

        int max = 3;
        int numberAdded = 0;

        for (int i = content.size() - 1; i >= 0; i--) {
            Stats.Quantity item = content.get(i);

            PropertyDetailView view = new PropertyDetailView(getContext());
            view.setProperty(item.getName());
            view.setDetail(Integer.toString(item.getQuantity()));
            mContentContainer.addView(view);

            if (++numberAdded >= max)
                break;
        }
    }
}
