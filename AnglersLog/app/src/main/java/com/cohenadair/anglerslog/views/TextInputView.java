package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A TextInputView is a view with a title and EditText view for input from the user..
 * Created by Cohen Adair on 2015-11-17.
 */
public class TextInputView extends LinearLayout {

    private TextView mTitle;
    private EditText mEditText;

    public TextInputView(Context context) {
        this(context, null);
        init(null);
    }

    public TextInputView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_text_input, this);

        mTitle = (TextView)findViewById(R.id.title_text_view);
        mEditText = (EditText)findViewById(R.id.edit_text);

        if (attrs != null) {
            TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.TextInputView, 0, 0);
            try {
                mTitle.setText(arr.getString(R.styleable.TextInputView_titleText));
                mEditText.setHint(arr.getString(R.styleable.TextInputView_editTextHint));
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

    public String getInputText() {
        return mEditText.getText().toString();
    }

    public void setInputText(String text) {
        mEditText.setText(text);
    }
    //endregion

    public void setOnEditTextChangeListener(TextInputWatcher watcher) {
        mEditText.addTextChangedListener(watcher);
    }

    /**
     * Convenience class/interface for TextInputView implementations.
     */
    public interface OnEditTextChangeListener {
        void onTextChanged(String s);
    }

    public static class TextInputWatcher implements TextWatcher {

        OnEditTextChangeListener mListener;

        public TextInputWatcher(OnEditTextChangeListener listener) {
            mListener = listener;
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            Log.d("", "Text changed!");
            mListener.onTextChanged(s.toString());
        }

        @Override
        public void afterTextChanged(Editable s) {

        }
    }
}
