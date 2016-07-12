package com.cohenadair.anglerslog.model.utilities;

import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

/**
 * The HasCatchesInterface is used for {@link UserDefineObject} subclasses that have catches
 * associated with them, such as a {@link Location} or {@link Bait}. This interface is required to
 * make the sorting implementation cleaner.
 *
 * @author Cohen Adair
 */
public interface HasCatchesInterface {
    // returns the number of fish caught
    // this is not the same as the number of catches
    // this takes Catch.quantity into account
    int getFishCaughtCount();
}
