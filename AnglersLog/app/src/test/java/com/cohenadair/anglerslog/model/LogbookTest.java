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
    public void testAddEntry() {
        Logbook.getSharedLogbook().addEntry(this.testCatch);
        assertTrue(Logbook.getSharedLogbook().entryCount() == 1);
    }

    @Test
    public void testRemoveEntry() {
        Logbook.getSharedLogbook().removeEntry(this.testCatch);
        assertTrue(Logbook.getSharedLogbook().entryCount() == 0);
    }

}