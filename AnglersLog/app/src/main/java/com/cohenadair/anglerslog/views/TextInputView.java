package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A TextInputView is a view with a title and EditText view for input from the user..
 * Created by Cohen Adair on 2015-11-17.
 * <p>
 * Note: An OnTextChangedListener shouldn't be used for the EditText in this class if the
 * UserDefineObject will be edited. Due to the lifecycle of Fragments, the callbacks are called
 * at odd times and will result in improper text values.
 * </p>
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

                if (arr.getBoolean(R.styleable.TextInputView_numbersOnly, false))
                    mEditText.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);

                if (arr.getBoolean(R.styleable.TextInputView_capSentencesOnly, false))
                    mEditText.setInputType(InputType.TYPE_TEXT_FLAG_MULTI_LINE | InputType.TYPE_TEXT_FLAG_CAP_SENTENCES);
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
        if (mEditText.getText().toString().equals(""))
            return null;
        return mEditText.getText().toString();
    }

    public void setInputText(String text) {
        mEditText.setText(text);
    }
    //endregion

    public void addOnInputTextChangedListener(TextWatcher listener) {
        mEditText.addTextChangedListener(listener);
    }
}
