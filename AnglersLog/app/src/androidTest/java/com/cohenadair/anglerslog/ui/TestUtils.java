package com.cohenadair.anglerslog.ui;

import android.support.test.espresso.ViewAction;
import android.support.test.espresso.contrib.DrawerActions;
import android.support.test.espresso.contrib.RecyclerViewActions;

import com.cohenadair.anglerslog.R;

import org.hamcrest.Matchers;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.action.ViewActions.replaceText;
import static android.support.test.espresso.action.ViewActions.scrollTo;
import static android.support.test.espresso.action.ViewActions.typeText;
import static android.support.test.espresso.assertion.ViewAssertions.doesNotExist;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.Visibility.VISIBLE;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withContentDescription;
import static android.support.test.espresso.matcher.ViewMatchers.withEffectiveVisibility;
import static android.support.test.espresso.matcher.ViewMatchers.withHint;
import static android.support.test.espresso.matcher.ViewMatchers.withId;
import static android.support.test.espresso.matcher.ViewMatchers.withText;

/**
 * A collection of useful UI testing methods.
 * @author Cohen Adair
 */
public class TestUtils {

    public static void performViewClick(int viewId) {
        onView(withId(viewId)).perform(click());
    }

    public static void performTextClick(int labelId) {
        onView(withText(labelId)).perform(click());
    }

    public static void performTextClick(String label) {
        onView(withText(label)).perform(click());
    }

    public static void performHintClick(int hintId) {
        onView(withHint(hintId)).perform(click());
    }

    public static void performDescriptionClick(int descriptionId) {
        onView(withContentDescription(descriptionId)).perform(click());
    }

    public static void performTypeText(int textEditId, String text) {
        onView(withId(textEditId)).perform(typeText(text));
    }

    public static void performHintTypeText(int hintId, String text) {
        onView(withHint(hintId)).perform(typeText(text));
    }

    public static void performReplaceText(int textEditId, String text) {
        onView(withId(textEditId)).perform(replaceText(text));
    }

    public static void openDrawer() {
        DrawerActions.openDrawer(R.id.main_drawer);
    }

    public static void selectDrawerItem(int labelId) {
        performTextClick(labelId);
    }

    public static void openAndSelectDrawerItem(int labelId) {
        openDrawer();
        selectDrawerItem(labelId);
    }

    public static void checkViewDisplayed(int viewId) {
        onView(withId(viewId)).check(matches(isDisplayed()));
    }

    public static void checkViewNotDisplayed(int viewId) {
        onView(withId(viewId)).check(doesNotExist());
    }

    public static void checkTextDisplayed(int labelId) {
        onView(withText(labelId)).check(matches(isDisplayed()));
    }

    public static void checkTextDisplayed(String label) {
        onView(withText(label)).check(matches(isDisplayed()));
    }

    public static void checkTextNotDisplayed(String label) {
        onView(withText(label)).check(doesNotExist());
    }

    public static void actionOnRecyclerViewItem(int id, int position, ViewAction action) {
        onView(withId(id)).perform(RecyclerViewActions.actionOnItemAtPosition(position, action));
    }

    public static void clickBackDescription() {
        performDescriptionClick(R.string.back_description);
    }

    public static void clickBackMenuButton() {
        onView(Matchers.allOf(withContentDescription(R.string.back_description), withEffectiveVisibility(VISIBLE))).perform(click());
    }

    public static void scrollToAndClickHint(int hintId) {
        onView(withHint(hintId)).perform(scrollTo(), click());
    }
}
