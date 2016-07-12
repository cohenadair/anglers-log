package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A SelectionSpinnerView is a view with a title and and a Spinner for selection.
 * @author Cohen Adair
 */
public class SelectionSpinnerView extends LinearLayout {

    private TextView mTitle;
    private Spinner mSpinner;

    public SelectionSpinnerView(Context context) {
        this(context, null);
        init(null);
    }

    public SelectionSpinnerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_selection_spinner, this);

        mTitle = (TextView)findViewById(R.id.title_text_view);
        mSpinner = (Spinner)findViewById(R.id.spinner);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.SelectionSpinnerView, 0, 0);
            try {
                mTitle.setText(arr.getString(R.styleable.SelectionSpinnerView_titleText));
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    //region Getters & Setters
    public String getTitle() {
        return mTitle.getText().toString();
    }

    public void setTitle(String title) {
        mTitle.setText(title);
    }

    public void setSelection(int position) {
        mSpinner.setSelection(position);
    }
    //endregion

    public void setAdapter(SpinnerAdapter adapter) {
        mSpinner.setAdapter(adapter);
    }

    public SpinnerAdapter getAdapter() {
        return mSpinner.getAdapter();
    }
}
