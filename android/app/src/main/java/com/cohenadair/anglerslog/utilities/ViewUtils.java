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

    /**
     * A wrapper for {@link TextView#setTextAppearance(int)}.
     */
    @TargetApi(Build.VERSION_CODES.M)
    @SuppressWarnings("deprecation")
    public static void setTextAppearance(Context context, TextView view, int resId) {
        if (Utils.isMinMarshmallow())
            view.setTextAppearance(resId);
        else
            view.setTextAppearance(context, resId);

    }

    /**
     * Either select or deselect the given View. If selected, the View is given a light background
     * color.
     *
     * @param view The View to select or deselect.
     * @param selected True to select, false to deselect.
     */
    public static void setSelected(View view, boolean selected) {
        view.setBackgroundResource(selected ? R.color.anglers_log_light_transparent : android.R.color.transparent);
    }

    /**
     * Hides or shows the given View.
     * @param view The View to hide or show.
     * @param visible True to show the View, false to hide it.
     */
    public static void setVisibility(View view, boolean visible) {
        if (view != null)
            view.setVisibility(visible ? View.VISIBLE : View.GONE);
    }

    /**
     * Adds a "Done" or check mark icon to the given {@link Toolbar}.
     * @param toolbar The {@link Toolbar} being added to.
     * @param onClick A callback for the "Done" menu button.
     */
    public static void addDoneButton(@NonNull Toolbar toolbar, MenuItem.OnMenuItemClickListener onClick) {
        MenuItem done = toolbar.getMenu().add(R.string.action_done);
        done.setIcon(R.drawable.ic_check);
        done.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
        done.setOnMenuItemClickListener(onClick);
    }

    /**
     * A wrapper for {@link TextWatcher#onTextChanged(CharSequence, int, int, int)}.
     */
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
