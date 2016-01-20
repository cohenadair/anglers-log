package com.cohenadair.anglerslog.model.user_defines;

/**
 * Represents a single Angler (fisher-person), added by the user.
 * Created by Cohen Adair on 2016-01-20.
 */
public class Angler extends UserDefineObject {

    public Angler(String name) {
        super(name);
    }

    public Angler(Angler angler) {
        super(angler);
    }

    public Angler(UserDefineObject obj) {
        super(obj);
    }

    public Angler(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }
}
