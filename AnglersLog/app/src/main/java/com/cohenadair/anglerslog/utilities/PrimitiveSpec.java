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

    String mName; // for TextEdit hint
    String mCapitalizedName; // for dialog title

    public PrimitiveSpec(String name, List<UserDefineObject> items, InteractionListener listener) {
        mName = name;
        mCapitalizedName = name.substring(0, 1).toUpperCase() + name.substring(1);
        mItems = items;
        mListener = listener;
    }

    /**
     * An interface for managing items in the RecyclerView.
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

    public String getCapitalizedName() {
        return mCapitalizedName;
    }
    //endregion

}
