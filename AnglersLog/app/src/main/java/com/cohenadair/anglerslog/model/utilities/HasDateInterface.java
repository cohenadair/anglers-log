package com.cohenadair.anglerslog.model.utilities;

import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.Date;

/**
 * The HasDateInterface is used for {@link UserDefineObject} subclasses that have a date
 * associated with them, such as a {@link Catch} or {@link Trip}. This interface is required to
 * make the sorting implementation cleaner.
 *
 * @author Cohen Adair
 */
public interface HasDateInterface {
    Date getDate();
}
