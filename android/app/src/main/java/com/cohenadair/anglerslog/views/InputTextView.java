package com.cohenadair.anglerslog.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.widget.EditText;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.ViewUtils;

/**
 * A TextInputView is a view with a title and EditText view for input from the user..
 * Created by Cohen Adair on 2015-11-17.
 * <p>
 * Note: An OnTextChangedListener shouldn't be used for the EditText in this class if the
 * UserDefineObject will be edited. Due to the lifecycle of Fragments, the callbacks are called
 * at odd times and will result in improper text values.
 * </p>
 *
 * @author Cohen Adair
 */
public class InputTextView extends LeftIconView {

    private TextView mTitleTextView;
    private EditText mEditText;

    public InputTextView(Context context) {
        this(context, null);
    }

    public InputTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        init(R.layout.view_input_text, attrs);

        mTitleTextView = (TextView)findViewById(R.id.title_text_view);
        mEditText = (EditText)findViewById(R.id.edit_text);

        if (attrs == null)
            return;

        TypedArray arr = getContext().getTheme().obtainStyledAttributes(attrs, R.styleable.InputTextView, 0, 0);

        try {
            // title
            String titleText = arr.getString(R.styleable.InputTextView_titleText);
            setTitle(titleText);

            // edit
            String editHint = arr.getString(R.styleable.InputTextView_editTextHint);
            mEditText.setHint(editHint);

            // TODO rename `numbersOnly` to `floatingNumbersOnly`
            if (arr.getBoolean(R.styleable.InputTextView_numbersOnly, false)) {
                allowPositiveFloatingNumbersOnly();
            }

            // TODO rename `capSentencesOnly` to `multilineCapSentencesOnly`
            if (arr.getBoolean(R.styleable.InputTextView_capSentencesOnly, false)) {
                allowMultilineCapSentencesOnly();
            }

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
            ViewUtils.setVisibility(mTitleTextView, false);
            return;
        }

        mTitleTextView.setText(title);
        ViewUtils.setVisibility(mTitleTextView, true);
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

    public void allowNegativeFloatingNumbersOnly() {
        mEditText.setInputType(
                InputType.TYPE_CLASS_NUMBER |
                InputType.TYPE_NUMBER_FLAG_DECIMAL |
                InputType.TYPE_NUMBER_FLAG_SIGNED
        );
    }

    public void allowNegativeWholeNumbersOnly() {
        mEditText.setInputType(
                InputType.TYPE_CLASS_NUMBER |
                InputType.TYPE_NUMBER_FLAG_SIGNED
        );
    }

    public void allowPositiveFloatingNumbersOnly() {
        mEditText.setInputType(
                InputType.TYPE_CLASS_NUMBER |
                InputType.TYPE_NUMBER_FLAG_DECIMAL
        );
    }

    public void allowPositiveWholeNumbersOnly() {
        mEditText.setInputType(
                InputType.TYPE_CLASS_NUMBER
        );
    }

    public void allowMultilineCapSentencesOnly() {
        mEditText.setInputType(
                InputType.TYPE_CLASS_TEXT |
                InputType.TYPE_TEXT_FLAG_MULTI_LINE |
                InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
        );
    }

    public void addOnInputTextChangedListener(TextWatcher listener) {
        mEditText.addTextChangedListener(listener);
    }

    public void pressBackspace() {
        mEditText.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL));
    }
}
