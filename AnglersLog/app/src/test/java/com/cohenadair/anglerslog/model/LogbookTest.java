package com.cohenadair.anglerslog.model;

import org.junit.Test;

import java.util.Date;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the Logbook (top level) class.
 * @author Cohen Adair
 */
public class LogbookTest {

    private Catch testCatch = new Catch(new Date());

    @Test
    public void testAddCatch() {
        Logbook.getSharedLogbook().addCatch(this.testCatch);
        assertTrue(Logbook.getSharedLogbook().catchCount() == 1);
    }

    @Test
    public void testRemoveCatch() {
        Logbook.getSharedLogbook().removeCatch(this.testCatch);
        assertTrue(Logbook.getSharedLogbook().catchCount() == 0);
    }

    @Test
    public void testCatchDated() {
        Date aDate = new Date(testCatch.getDate().getTime());
        Logbook.getSharedLogbook().addCatch(testCatch);

        assertFalse(aDate == testCatch.getDate()); // date references are different
        assertTrue(Logbook.getSharedLogbook().catchDated(aDate) != null); // date values are the same

        Logbook.getSharedLogbook().removeCatch(testCatch);
    }

}