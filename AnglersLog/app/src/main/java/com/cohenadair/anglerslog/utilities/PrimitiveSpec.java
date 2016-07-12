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
 * @author Cohen Adair
 */
public class PrimitiveSpec {

    InteractionListener mListener;
    String mName;

    public PrimitiveSpec(String name, InteractionListener listener) {
        mName = name.toLowerCase();
        mListener = listener;
    }

    /**
     * An interface for managing items in a RecyclerView.
     */
    public interface InteractionListener {
        ArrayList<UserDefineObject> onGetItems();
        UserDefineObject onClickItem(UUID id);
        boolean onAddItem(String name);
        boolean onRemoveItem(UUID id);
        void onEditItem(UUID id, UserDefineObject newObj);
    }

    //region Getters & Setters
    public InteractionListener getListener() {
        return mListener;
    }

    public String getName() {
        return mName;
    }

    public ArrayList<UserDefineObject> getItems() {
        return mListener.onGetItems();
    }
    //endregion

}
