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

    public void init(String title, String buttonText, ArrayList<Stats.Quantity> content, OnClickListener onClickButton) {
        setTitle(title);
        setOnClickShowMoreButton(onClickButton);

        if (buttonText != null)
            mShowMoreButton.setText(buttonText);

        updateContent(content);
    }

    public void init(String title, ArrayList<Stats.Quantity> content, OnClickListener onClickButton) {
        init(title, null, content, onClickButton);
    }

    public void setTitle(String title) {
        mTitleView.setText(title);
    }

    public void setOnClickShowMoreButton(OnClickListener listener) {
        mShowMoreButton.setOnClickListener(listener);
    }

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

        // hide button/adjust content layout if needed
        boolean showButton = content.size() > 3;
        Utils.toggleVisibility(mShowMoreButton, showButton);
        LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        params.setMargins(
                0,
                0,
                0,
                showButton ? 0 : getResources().getDimensionPixelSize(R.dimen.margin_default)
        );
        mContentContainer.setLayoutParams(params);
    }
}
