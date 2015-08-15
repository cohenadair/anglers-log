package com.cohenadair.anglerslog.model;

import org.junit.Test;

import java.util.Date;

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

}