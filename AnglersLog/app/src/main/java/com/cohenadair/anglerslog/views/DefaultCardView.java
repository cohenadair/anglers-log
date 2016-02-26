package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

/**
 * A DefaultCardView is a view that displays a default styled {@link android.support.v7.widget.CardView}.
 * Created by Cohen Adair on 2016-01-26.
 */
public class DefaultCardView extends LinearLayout {

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

    public void initWithMoreDetailView(String cardTitle, String moreDetailTitle, String moreDetailSubtitle, OnClickListener onClickMoreDetail, OnClickListener onClickCard) {
        setTitle(cardTitle);
        setOnClickShowMoreButton(onClickCard);

        MoreDetailView view = new MoreDetailView(getContext());
        view.setTitle(moreDetailTitle);
        view.setSubtitle(moreDetailSubtitle);
        view.setOnClickDetailButton(onClickMoreDetail);
        view.useDefaultStyle();
        view.useSmallSpacing();
        mContentContainer.addView(view);
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
        Utils.toggleVisibility(this, content.size() > 0);

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
