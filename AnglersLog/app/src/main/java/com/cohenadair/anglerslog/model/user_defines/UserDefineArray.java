package com.cohenadair.anglerslog.model.user_defines;

import java.util.ArrayList;

/**
 * The UserDefineArray class is used to store user defined arrays.
 * Created by Cohen Adair on 2015-09-07.
 */
public class UserDefineArray {

    private ArrayList<UserDefineObject> mItems = new ArrayList<>();

    public UserDefineArray() {

    }

    //region Getters & Setters
    public ArrayList<UserDefineObject> getItems() {
        return mItems;
    }

    public void setItems(ArrayList<UserDefineObject> items) {
        mItems = items;
    }
    //endregion

    public boolean add(UserDefineObject item) {
        return mItems.add(item);
    }

    public boolean remove(UserDefineObject item) {
        return mItems.remove(item);
    }

    public int size() {
        return mItems.size();
    }

    /**
     * Checks for an object with the given name.
     * @param name the name to look for.
     * @return a UserDefineObject subclass with the given name.
     */
    public UserDefineObject itemWithName(String name) {
        for (UserDefineObject obj : mItems)
            if (obj.getName().equals(name))
                return obj;

        return null;
    }

    /**
     * Retrieves the names of every object in the items array.
     * @return an ArrayList<CharSequence> of object names.
     */
    public ArrayList<CharSequence> nameList() {
        ArrayList<CharSequence> names = new ArrayList<>();

        for (UserDefineObject obj : mItems)
            names.add(obj.getName());

        return names;
    }

    /**
     * Retrives the item at a certain position.
     * @param position the position or index of the item to be found.
     * @return a UserDefineObject at the given position.
     */
    public UserDefineObject get(int position) {
        return mItems.get(position);
    }

}
