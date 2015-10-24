package com.cohenadair.anglerslog.utilities;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.List;

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

    List<UserDefineObject> mItems;
    InteractionListener mListener;
    String mName;

    public PrimitiveSpec(String name, List<UserDefineObject> items, InteractionListener listener) {
        mName = name;
        mItems = items;
        mListener = listener;
    }

    /**
     * An interface for managing items in a RecyclerView.
     */
    public interface InteractionListener {
        UserDefineObject onClickItem(int position);
        boolean onAddItem(String name);
        void onEditItem(int position, String newName);
        void onConfirmDelete();
    }

    //region Getters & Setters
    public List<UserDefineObject> getItems() {
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
