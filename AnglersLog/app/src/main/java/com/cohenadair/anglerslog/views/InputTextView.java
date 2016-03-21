package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.Utils;

/**
 * A TextInputView is a view with a title and EditText view for input from the user..
 * Created by Cohen Adair on 2015-11-17.
 * <p>
 * Note: An OnTextChangedListener shouldn't be used for the EditText in this class if the
 * UserDefineObject will be edited. Due to the lifecycle of Fragments, the callbacks are called
 * at odd times and will result in improper text values.
 * </p>
 */
public class InputTextView extends LinearLayout {

    private ImageView mIconImageView;
    private TextView mTitleTextView;
    private EditText mEditText;

    public InputTextView(Context context) {
        this(context, null);
        init(null);
    }

    public InputTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.view_input_text, this);

        mIconImageView = (ImageView)findViewById(R.id.icon_image_view);
        mTitleTextView = (TextView)findViewById(R.id.title_text_view);
        mEditText = (EditText)findViewById(R.id.edit_text);

        if (attrs == null)
            return;

        TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.InputTextView, 0, 0);

        try {
            // icon
            int iconResId = arr.getResourceId(R.styleable.InputTextView_iconResource, -1);
            setIconResource(iconResId);

            // title
            String titleText = arr.getString(R.styleable.InputTextView_titleText);
            mTitleTextView.setText(titleText);

            // edit
            String editHint = arr.getString(R.styleable.InputTextView_editTextHint);
            mEditText.setHint(editHint);

            setNumbersOnly(arr.getBoolean(R.styleable.InputTextView_numbersOnly, false));
            setCapSentencesOnly(arr.getBoolean(R.styleable.InputTextView_capSentencesOnly, false));

        } finally {
            arr.recycle(); // required after using TypedArray
        }
    }

    //region Getters & Setters
    public String getTitle() {
        return mTitleTextView.getText().toString();
    }

    public void setTitle(String title) {
        if (Utils.stringOrNull(title) == null) {
            Utils.toggleVisibility(mTitleTextView, false);
            return;
        }

        mTitleTextView.setText(title);
        Utils.toggleVisibility(mTitleTextView, true);
    }

    public String getInputText() {
        if (mEditText.getText().toString().equals(""))
            return null;
        return mEditText.getText().toString();
    }

    public void setInputText(String text) {
        mEditText.setText(text);
    }

    public void setHint(String hint) {
        mEditText.setHint(hint);
    }

    public void setIconResource(int resId) {
        if (resId == -1) {
            Utils.toggleVisibility(mIconImageView, false);
            return;
        }

        mIconImageView.setImageResource(resId);
        Utils.toggleVisibility(mIconImageView, true);
    }
    //endregion

    public void setAllowsNegativeNumbers(boolean allowsNegativeNumbers) {
        if (!allowsNegativeNumbers)
            return;

        mEditText.setInputType(
                InputType.TYPE_CLASS_NUMBER |
                InputType.TYPE_NUMBER_FLAG_DECIMAL |
                InputType.TYPE_NUMBER_FLAG_SIGNED
        );
    }

    public void setNumbersOnly(boolean numbersOnly) {
        if (!numbersOnly)
            return;

        mEditText.setInputType(
                InputType.TYPE_CLASS_NUMBER |
                InputType.TYPE_NUMBER_FLAG_DECIMAL
        );
    }

    public void setCapSentencesOnly(boolean capSentencesOnly) {
        if (!capSentencesOnly)
            return;

        mEditText.setInputType(
                InputType.TYPE_CLASS_TEXT |
                InputType.TYPE_TEXT_FLAG_MULTI_LINE |
                InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
        );
    }

    public void setTitleVisibility(boolean visible) {
        Utils.toggleVisibility(mTitleTextView, visible);
    }

    public void addOnInputTextChangedListener(TextWatcher listener) {
        mEditText.addTextChangedListener(listener);
    }
}
