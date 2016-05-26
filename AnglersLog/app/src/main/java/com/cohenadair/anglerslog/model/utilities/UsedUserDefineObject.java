package com.cohenadair.anglerslog.model.utilities;

import android.content.ContentValues;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.user_defines.FishingMethod;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The UsedUserDefineObject is a utility class used to interact with the database for
 * UserDefineObject subclasses that are used in other UserDefineObjects. For example, a
 * {@link com.cohenadair.anglerslog.model.user_defines.Catch} can have multiple
 * {@link FishingMethod}s which are stored in a separate database table.
 *
 * This class is used to extract those {@link FishingMethod}s or other "used"
 * {@link UserDefineObject}s.
 *
 * @author Cohen Adair
 */
public class UsedUserDefineObject {

    private UUID mSuperId; // the id of the UserDefineObject this object belongs to
    private String mTable;
    private String mSuperColumnId;
    private String mChildColumnId;

    public UsedUserDefineObject(UUID superId, String table, String superColumnId, String childColumnId) {
        mSuperId = superId;
        mTable = table;
        mSuperColumnId = superColumnId;
        mChildColumnId = childColumnId;
    }

    public ArrayList<UserDefineObject> getObjects(QueryHelper.UsedQueryCallbacks callbacks) {
        return QueryHelper.queryUsedUserDefineObject(mTable, mChildColumnId, mSuperColumnId, mSuperId, callbacks);
    }

    public void setObjects(ArrayList<UserDefineObject> objects) {
        if (objects == null)
            return;

        deleteObjects();
        addObjects(objects);
    }

    public void deleteObjects() {
        QueryHelper.deleteQuery(mTable, mSuperColumnId + " = ?", new String[]{ mSuperId.toString() });
    }

    private void addObjects(ArrayList<UserDefineObject> objects) {
        for (UserDefineObject obj : objects)
            QueryHelper.insertQuery(mTable, getContentValues(obj));
    }

    private ContentValues getContentValues(UserDefineObject obj) {
        ContentValues values = new ContentValues();

        values.put(mSuperColumnId, mSuperId.toString());
        values.put(mChildColumnId, obj.getIdAsString());

        return values;
    }
}
