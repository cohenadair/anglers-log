package com.cohenadair.anglerslog.utilities;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * LayoutSpec is used to store layout information to utilize similar code throughout the
 * application.  For example, viewing and managing primitive
 * {@link com.cohenadair.anglerslog.model.user_defines.UserDefineObject}s such as
 * {@link com.cohenadair.anglerslog.model.user_defines.Species}, all use the same
 * simple {@link com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment} for adding, editing,
 * and deleting.
 *
 * Created by Cohen Adair on 2015-09-03.
 */
public class PrimitiveSpec {

    ArrayList<UserDefineObject> mItems;
    InteractionListener mListener;
    String mName;

    public PrimitiveSpec(String name, ArrayList<UserDefineObject> items, InteractionListener listener) {
        mName = name;
        mItems = items;
        mListener = listener;
    }

    /**
     * An interface for managing items in a RecyclerView.
     */
    public interface InteractionListener {
        UserDefineObject onClickItem(UUID id);
        boolean onAddItem(String name);
        void onEditItem(UUID id, UserDefineObject newObj);
        void onConfirmDelete();
    }

    //region Getters & Setters
    public ArrayList<UserDefineObject> getItems() {
        return mItems;
    }

    public InteractionListener getListener() {
        return mListener;
    }

    public String getName() {
        return mName;
    }
    //endregion

}
