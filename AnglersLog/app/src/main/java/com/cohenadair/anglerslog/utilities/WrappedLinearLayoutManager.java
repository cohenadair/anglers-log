package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

/**
 * A wrapper class for {@link LinearLayoutManager} that calculates the height of the associated
 * {@link RecyclerView} to wrap its contents. Class derived from:
 * http://stackoverflow.com/questions/27475178/how-do-i-make-wrap-content-work-on-a-recyclerview
 *
 * @author Cohen Adair
 */
public class WrappedLinearLayoutManager extends LinearLayoutManager {

    public WrappedLinearLayoutManager(Context context)    {
        super(context);
    }

    @Override
    public void onMeasure(RecyclerView.Recycler recycler, RecyclerView.State state, int widthSpec, int heightSpec) {
        final int heightMode = View.MeasureSpec.getMode(heightSpec);
        final int heightSize = View.MeasureSpec.getSize(heightSpec);

        int width = 0;
        int height = 0;

        for (int i = 0; i < getItemCount(); i++) {
            height += childHeight(recycler, i,
                    View.MeasureSpec.makeMeasureSpec(i, View.MeasureSpec.UNSPECIFIED),
                    View.MeasureSpec.makeMeasureSpec(i, View.MeasureSpec.UNSPECIFIED));
        }

        switch (heightMode) {
            case View.MeasureSpec.EXACTLY:
                height = heightSize;
            case View.MeasureSpec.AT_MOST:
            case View.MeasureSpec.UNSPECIFIED:
        }

        setMeasuredDimension(widthSpec, height);
    }

    private int childHeight(RecyclerView.Recycler recycler, int position, int widthSpec, int heightSpec) {
        View view = recycler.getViewForPosition(position);

        if (view != null) {
            RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) view.getLayoutParams();

            int childHeightSpec = ViewGroup.getChildMeasureSpec(heightSpec, getPaddingTop() + getPaddingBottom(), params.height);
            view.measure(widthSpec, childHeightSpec);

            int result = view.getMeasuredHeight() + params.bottomMargin + params.topMargin;
            recycler.recycleView(view);

            return result;
        }

        return 0;
    }
}
