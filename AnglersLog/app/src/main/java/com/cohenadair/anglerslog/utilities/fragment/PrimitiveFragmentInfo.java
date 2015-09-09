package com.cohenadair.anglerslog.utilities.fragment;

import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.List;

/**
 * The PrimitiveFragmentInfo is used to store information on "primitive" fragments. Primitive
 * fragments are for managing user defines that do not have a complex object structure. For example,
 * a Species, or FishingMethod only has a name attribute.
 *
 * Created by Cohen Adair on 2015-09-08.
 */
public class PrimitiveFragmentInfo {

    List<UserDefineObject> mItems;
    Interface mInterface;

    /**
     * Used for displaying titles and hint
     */
    String mName;
    String mCapitalizedName;

    /**
     * An interface for managing items in the ListView.
     */
    public interface Interface {
        boolean onAddItem(String name);
        UserDefineObject onClickItem(int position);
    }

    //region Getters & Setters
    public List<UserDefineObject> getItems() {
        return mItems;
    }

    public void setItems(List<UserDefineObject> items) {
        mItems = items;
    }

    public Interface getInterface() {
        return mInterface;
    }

    public void setInterface(Interface anInterface) {
        mInterface = anInterface;
    }

    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public String getCapitalizedName() {
        return mCapitalizedName;
    }

    public void setCapitalizedName(String capitalizedName) {
        mCapitalizedName = capitalizedName;
    }
    //endregion
}
