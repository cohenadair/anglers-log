package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A PropertyDetailView is a view that neatly displays a property and detail text horizontally.
 * @author Cohen Adair
 */
public class PropertyDetailView extends LinearLayout {

    private TextView mProperty;
    private TextView mDetail;

    public PropertyDetailView(Context context) {
        super(context);
        init(null);
    }

    public PropertyDetailView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_property_detail, this);

        mProperty = (TextView)findViewById(R.id.property_text_view);
        mDetail = (TextView)findViewById(R.id.detail_text_view);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.PropertyDetailView, 0, 0);
            try {
                mProperty.setText(arr.getString(R.styleable.PropertyDetailView_propertyName));
            } finally {
                arr.recycle(); // required after using TypedArray
            }
        }
    }

    //region Getters & Setters
    public String getProperty() {
        return mProperty.getText().toString();
    }

    public void setProperty(String title) {
        mProperty.setText(title);
    }

    public String getDetail() {
        return mDetail.getText().toString();
    }

    public void setDetail(String detail) {
        mDetail.setText(detail);
    }
    //endregion
}
