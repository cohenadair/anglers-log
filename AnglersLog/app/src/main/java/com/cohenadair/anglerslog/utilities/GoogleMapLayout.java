package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.view.MotionEvent;
import android.widget.FrameLayout;

/**
 * A wrapper class for use with a GoogleMap object.
 * @author Cohen Adair
 */
public class GoogleMapLayout extends FrameLayout {

    public interface OnDragListener {
        void onDrag(MotionEvent motionEvent);
    }

    private OnDragListener mOnDragListener;

    public GoogleMapLayout(Context context) {
        super(context);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (mOnDragListener != null && ev.getAction() == MotionEvent.ACTION_UP)
            mOnDragListener.onDrag(ev);

        return super.dispatchTouchEvent(ev);
    }

    public void setOnDragListener(OnDragListener mOnDragListener) {
        this.mOnDragListener = mOnDragListener;
    }

}
