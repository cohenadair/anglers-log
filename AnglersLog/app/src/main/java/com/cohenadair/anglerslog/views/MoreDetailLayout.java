package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A MoreDetailLayout is a layout that displays a list of a {@link MoreDetailView}s. It will
 * display a set number of views until the "more" button is clicked.
 *
 * Created by Cohen Adair on 2016-01-25.
 */
public class MoreDetailLayout extends LinearLayout {

    /**
     * An interface used for creating a list of {@link MoreDetailView}s.
     */
    public interface OnUpdateItemInterface {
        String getTitle(UserDefineObject object);
        String getSubtitle(UserDefineObject object);
        View.OnClickListener onClickItemButton(UUID id);
    }

    private LinearLayout mListContainer;
    private Button mShowMoreButton;
    private View mTitleView;

    private int mItemsShown = 0;
    private ArrayList<UserDefineObject> mObjects;
    private OnUpdateItemInterface mCallbacks;

    public MoreDetailLayout(Context context) {
        this(context, null);
        init();
    }

    public MoreDetailLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.layout_more_detail, this);

        mListContainer = (LinearLayout)findViewById(R.id.list_container);

        mShowMoreButton = (Button)findViewById(R.id.show_more_button);
        mShowMoreButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                updateViews();
            }
        });
    }

    public void init(View titleView, ArrayList<UserDefineObject> items, OnUpdateItemInterface onUpdateItemInterface) {
        mItemsShown = 0;
        mTitleView = titleView;
        mObjects = items;
        mCallbacks = onUpdateItemInterface;
        mListContainer.removeAllViews();
        updateViews();
    }

    /**
     * Needs to be called after initialization.
     */
    public void updateViews() {
        boolean hasObjects = mObjects.size() > 0;
        Utils.toggleVisibility(mTitleView, hasObjects);
        Utils.toggleVisibility(mListContainer, hasObjects);

        for (int i = mItemsShown; i < mObjects.size(); i++) {
            UserDefineObject object = mObjects.get(i);
            MoreDetailView view = new MoreDetailView(getContext());
            view.setTitle(mCallbacks.getTitle(object));
            view.useDefaultStyle();

            if (mCallbacks.getSubtitle(object) == null)
                view.hideSubtitle();
            else
                view.setSubtitle(mCallbacks.getSubtitle(object));

            if (mObjects.size() == 1)
                view.useSmallSpacing();
            else
                view.useDefaultSpacing();

            view.setOnClickDetailButton(mCallbacks.onClickItemButton(object.getId()));
            mListContainer.addView(view);
            mItemsShown++;

            // if the items displayed is a multiple of 3
            if (mItemsShown % 3 == 0)
                break;
        }

        Utils.toggleVisibility(mShowMoreButton, mItemsShown < mObjects.size());
    }
}
