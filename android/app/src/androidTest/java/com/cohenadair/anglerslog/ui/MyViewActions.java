package com.cohenadair.anglerslog.ui;

import android.support.annotation.NonNull;
import android.support.test.espresso.UiController;
import android.support.test.espresso.ViewAction;
import android.view.View;

import org.hamcrest.Matcher;

/**
 * A collection of custom view actions.
 * Cohen Adair
 */
public class MyViewActions {

    /**
     * Clicks the child View with a given id. Derived from:
     * http://stackoverflow.com/questions/28476507/using-espresso-to-click-view-inside-recyclerview-item
     * @param id The id of the child.
     */
    @NonNull
    public static ViewAction clickChildView(final int id) {
        return new ViewAction() {
            @Override
            public Matcher<View> getConstraints() {
                return null;
            }

            @Override
            public String getDescription() {
                return null;
            }

            @Override
            public void perform(UiController uiController, View view) {
                View v = view.findViewById(id);
                if (v != null)
                    v.performClick();
            }
        };
    }

}
