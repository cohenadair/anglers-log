package com.cohenadair.anglerslog.model;

import java.util.Comparator;
import java.util.UUID;

/**
 * Stores anything used by the application's stats features.
 * @author Cohen Adair
 */
public class Stats {

    public static class Quantity {
        private UUID mId;
        private String mName;
        private int mQuantity;

        public Quantity(UUID id, String name, int quantity) {
            mId = id;
            mName = name;
            mQuantity = quantity;
        }

        public UUID getId() {
            return mId;
        }

        public String getName() {
            return mName;
        }

        public int getQuantity() {
            return mQuantity;
        }
    }

    public static class QuantityComparator implements Comparator<Quantity> {
        @Override
        public int compare(Quantity lhs, Quantity rhs) {
            if (lhs.getQuantity() < rhs.getQuantity())
                return -1;
            else if (lhs.getQuantity() == rhs.getQuantity())
                return 0;
            else
                return 1;
        }
    }

    public static class NameComparator implements  Comparator<Quantity> {
        @Override
        public int compare(Quantity lhs, Quantity rhs) {
            return lhs.getName().compareTo(rhs.getName());
        }
    }

}
