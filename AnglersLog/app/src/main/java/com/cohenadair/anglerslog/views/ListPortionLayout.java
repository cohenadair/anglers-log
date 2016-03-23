package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;

/**
 * A ListPortionLayout is a layout that displays a portion of a
 * {@link android.support.v7.widget.RecyclerView}.
 *
 * @author Cohen Adair
 */
public class ListPortionLayout extends LinearLayout {

    public interface InteractionListener {
        ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items);
        void onClickAllButton(ArrayList<UserDefineObject> items);
    }

    private ImageView mIconImageView;
    private Button mShowAllButton;
    private RecyclerView mRecyclerView;

    private InteractionListener mCallbacks;
    private ArrayList<UserDefineObject> mAllItems;
    private ArrayList<UserDefineObject> mPortionItems;

    public ListPortionLayout(Context context) {
        this(context, null);
        init();
    }

    public ListPortionLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.layout_list_portion, this);

        mIconImageView = (ImageView)findViewById(R.id.icon_image_view);

        mRecyclerView = (RecyclerView)findViewById(R.id.recycler_view);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        mRecyclerView.setLayoutFrozen(true);

        mShowAllButton = (Button)findViewById(R.id.show_all_button);
        mShowAllButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onClickAllButton(mAllItems);
            }
        });
    }

    public void init(int iconResId, ArrayList<UserDefineObject> items, InteractionListener callbacks) {
        mCallbacks = callbacks;
        mAllItems = items;
        mPortionItems = getPortionItems(mAllItems);

        mIconImageView.setImageResource(iconResId);
        mRecyclerView.setAdapter(mCallbacks.onGetAdapter(mPortionItems));

        updateViews();
    }

    private ArrayList<UserDefineObject> getPortionItems(ArrayList<UserDefineObject> allItems) {
        ArrayList<UserDefineObject> newItems = new ArrayList<>();

        for (int i = 0; i < 3; i++) {
            if (i > allItems.size() - 1)
                break;

            newItems.add(allItems.get(i));
        }

        return newItems;
    }

    /**
     * Needs to be called after initialization.
     */
    public void updateViews() {
        boolean hasObjects = getPortionCount() > 0;

        // hide views if needed
        Utils.toggleVisibility(mIconImageView, hasObjects);
        Utils.toggleVisibility(findViewById(R.id.container), hasObjects);

        boolean shouldShowMore = getAllCount() > getPortionCount();
        Utils.toggleVisibility(mShowAllButton, shouldShowMore);

        // give the RecyclerView a margin if it is showing all possible items
        if (!shouldShowMore) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)mRecyclerView.getLayoutParams();
            params.setMargins(
                    0,
                    0,
                    0,
                    getResources().getDimensionPixelSize(R.dimen.margin_default)
            );

            mRecyclerView.setLayoutParams(params);
        }
    }

    public void setButtonText(int resId) {
        mShowAllButton.setText(resId);
    }

    private int getPortionCount() {
        return mPortionItems.size();
    }

    private int getAllCount() {
        return mAllItems.size();
    }
}
