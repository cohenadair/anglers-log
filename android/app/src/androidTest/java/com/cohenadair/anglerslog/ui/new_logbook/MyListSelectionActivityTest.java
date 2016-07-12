package com.cohenadair.anglerslog.ui.new_logbook;

import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;
import android.test.suitebuilder.annotation.LargeTest;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.MainActivity;

import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.action.ViewActions.longClick;
import static com.cohenadair.anglerslog.ui.TestUtils.actionOnRecyclerViewItem;
import static com.cohenadair.anglerslog.ui.TestUtils.checkTextDisplayed;
import static com.cohenadair.anglerslog.ui.TestUtils.checkTextNotDisplayed;
import static com.cohenadair.anglerslog.ui.TestUtils.clickBackMenuButton;
import static com.cohenadair.anglerslog.ui.TestUtils.openAndSelectDrawerItem;
import static com.cohenadair.anglerslog.ui.TestUtils.performHintClick;
import static com.cohenadair.anglerslog.ui.TestUtils.performHintTypeText;
import static com.cohenadair.anglerslog.ui.TestUtils.performReplaceText;
import static com.cohenadair.anglerslog.ui.TestUtils.performTextClick;
import static com.cohenadair.anglerslog.ui.TestUtils.performTypeText;
import static com.cohenadair.anglerslog.ui.TestUtils.performViewClick;

/**
 * UI automated tests for managing {@link com.cohenadair.anglerslog.model.user_defines.Catch}
 * and {@link com.cohenadair.anglerslog.model.user_defines.Location} objects from a
 * {@link com.cohenadair.anglerslog.activities.MyListSelectionActivity} instance.
 *
 * @author Cohen Adair
 */
@RunWith(AndroidJUnit4.class)
@LargeTest
public class MyListSelectionActivityTest {

    @Rule
    public ActivityTestRule<MainActivity> mActivityRule = new ActivityTestRule<>(MainActivity.class);

    @Before
    public void setUp() {
        openAndSelectDrawerItem(R.string.drawer_trips);
        performViewClick(R.id.new_button);
    }

    @After
    public void tearDown() {
        clickBackMenuButton();
        clickBackMenuButton();
    }

    @Test
    public void testCatches() {
        performHintClick(R.string.add_catches);

        String speciesOne = "Bass - Smallmouth";
        String speciesTwo = "Pike";

        // add catch
        performViewClick(R.id.new_button);
        performHintClick(R.string.add_species);
        actionOnRecyclerViewItem(R.id.content_recycler_view, 0, click());
        performViewClick(R.id.action_confirm);

        // edit catch
        actionOnRecyclerViewItem(R.id.main_recycler_view, 0, longClick());
        performTextClick(R.string.action_edit);
        performTextClick(speciesOne);
        performTextClick(speciesTwo);
        performViewClick(R.id.action_confirm);
        checkTextDisplayed(speciesTwo);

        // delete catch
        actionOnRecyclerViewItem(R.id.main_recycler_view, 0, longClick());
        performTextClick(R.string.action_delete);
        performTextClick(R.string.action_delete);
        checkTextNotDisplayed(speciesTwo);
    }

    @Test
    public void testLocations() {
        performHintClick(R.string.add_locations);

        String testLocation = "Test Location";
        String testLocationTwo = "Test Location Two";
        String testSpot = "Test Fishing Spot";

        // add location
        performViewClick(R.id.new_button);
        performTypeText(R.id.edit_text, testLocation);
        performHintClick(R.string.add_fishing_spot);
        performHintTypeText(R.string.add_name, testSpot);
        performViewClick(R.id.done_button);
        performViewClick(R.id.action_confirm);

        // edit location
        actionOnRecyclerViewItem(R.id.main_recycler_view, 0, longClick());
        performTextClick(R.string.action_edit);
        performReplaceText(R.id.edit_text, testLocationTwo);
        performViewClick(R.id.action_confirm);
        checkTextDisplayed(testLocationTwo);

        // delete location
        actionOnRecyclerViewItem(R.id.main_recycler_view, 0, longClick());
        performTextClick(R.string.action_delete);
        performTextClick(R.string.action_delete);
        checkTextNotDisplayed(testLocationTwo);
    }

}
