package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetBehavior;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A BottomSheetView is a wrapper for {@link android.support.design.widget.BottomSheetBehavior} as
 * part of Google Material Design Pattern.
 *
 * @author Cohen Adair
 */
public class BottomSheetView extends LinearLayout {

    private TextView mTitleTextView;
    private TextView mDescriptionTextView;
    private Button mCloseButton;

    private BottomSheetBehavior mBehavior;
    private InteractionListener mCallbacks;

    public interface InteractionListener {
        void onDismiss();
    }

    public BottomSheetView(Context context) {
        this(context, null);
    }

    public BottomSheetView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.view_bottom_sheet, this);
        mTitleTextView = (TextView)findViewById(R.id.title_text_view);
        mDescriptionTextView = (TextView)findViewById(R.id.description_text_view);
        mCloseButton = (Button)findViewById(R.id.close_button);
    }

    public void init(View bottomSheet, int icon, int title, int description, int buttonText, boolean show, InteractionListener callbacks) {
        mCallbacks = callbacks;
        mBehavior = BottomSheetBehavior.from(bottomSheet);
        mTitleTextView.setText(title);
        mTitleTextView.setCompoundDrawablesWithIntrinsicBounds(icon, 0, 0, 0);
        mDescriptionTextView.setText(description);
        mCloseButton.setText(buttonText);

        mBehavior.setBottomSheetCallback(new BottomSheetBehavior.BottomSheetCallback() {
            @Override
            public void onStateChanged(@NonNull View bottomSheet, int newState) {

            }

            @Override
            public void onSlide(@NonNull View bottomSheet, float slideOffset) {

            }
        });

        mCloseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCallbacks != null)
                    mCallbacks.onDismiss();

                collapse();
            }
        });

        // must be done after the layout is inflated
        if (show)
            bottomSheet.post(new Runnable() {
                @Override
                public void run() {
                    expand();
                }
            });
    }

    public void expand() {
        mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
    }

    public void collapse() {
        mBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
    }

}
