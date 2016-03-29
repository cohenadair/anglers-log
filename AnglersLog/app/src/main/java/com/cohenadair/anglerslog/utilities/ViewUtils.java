package com.cohenadair.anglerslog.utilities;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;

/**
 * A collection of {@link View} related utility methods.
 * @author Cohen Adair
 */
public class ViewUtils {

    @TargetApi(Build.VERSION_CODES.M)
    @SuppressWarnings("deprecation")
    public static void setTextAppearance(Context context, TextView view, int resId) {
        if (Utils.isMinMarshmallow())
            view.setTextAppearance(resId);
        else
            view.setTextAppearance(context, resId);

    }

    public static void setSelected(View view, boolean selected) {
        view.setBackgroundResource(selected ? R.color.anglers_log_light_transparent : android.R.color.transparent);
    }

    public static void setVisibility(View view, boolean visible) {
        if (view != null)
            view.setVisibility(visible ? View.VISIBLE : View.GONE);
    }

    public static void addDoneButton(@NonNull Toolbar toolbar, MenuItem.OnMenuItemClickListener onClick) {
        MenuItem done = toolbar.getMenu().add(R.string.action_done);
        done.setIcon(R.drawable.ic_check);
        done.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
        done.setOnMenuItemClickListener(onClick);
    }

    public interface OnTextChangedListener {
        void onTextChanged(String newText);
    }

    @NonNull
    public static TextWatcher onTextChangedListener(final OnTextChangedListener listener) {
        return new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                listener.onTextChanged(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        };
    }

}
