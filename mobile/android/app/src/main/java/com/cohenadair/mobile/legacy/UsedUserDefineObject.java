package com.cohenadair.mobile.legacy;

import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.user_defines.FishingMethod;
import com.cohenadair.mobile.legacy.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The UsedUserDefineObject is a utility class used to interact with the database for
 * UserDefineObject subclasses that are used in other UserDefineObjects. For example, a
 * {@link com.cohenadair.mobile.legacy.user_defines.Catch} can have multiple
 * {@link FishingMethod}s which are stored in a separate database table.
 *
 * This class is used to extract those {@link FishingMethod}s or other "used"
 * {@link UserDefineObject}s.
 *
 * @author Cohen Adair
 */
public class UsedUserDefineObject {
    private final UUID mSuperId; // the id of the UserDefineObject this object belongs to
    private final String mTable;
    private final String mSuperColumnId;
    private final String mChildColumnId;

    public UsedUserDefineObject(UUID superId, String table, String superColumnId, String childColumnId) {
        mSuperId = superId;
        mTable = table;
        mSuperColumnId = superColumnId;
        mChildColumnId = childColumnId;
    }

    public ArrayList<UserDefineObject> getObjects(QueryHelper.UsedQueryCallbacks callbacks) {
        return QueryHelper.queryUsedUserDefineObject(mTable, mChildColumnId, mSuperColumnId, mSuperId, callbacks);
    }
}
