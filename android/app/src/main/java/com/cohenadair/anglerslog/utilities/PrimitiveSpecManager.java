package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Angler;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.FishingMethod;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.user_defines.WaterClarity;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A controller object used to retrieve managing information for a primitive
 * {@link UserDefineObject} such as {@link Species}.
 *
 * @author Cohen Adair
 */
public class PrimitiveSpecManager {

    public static final int SPECIES = 0;
    public static final int BAIT_CATEGORY = 1;
    public static final int WATER_CLARITY = 2;
    public static final int FISHING_METHODS = 3;
    public static final int ANGLERS = 4;

    // force singleton
    private PrimitiveSpecManager() { }

    /**
     * Gets a {@link PrimitiveSpec} object associated with a specified id.
     * @param id The id of the spec.
     * @return A PrimitiveSpec object associated with id or null if one doesn't exist.
     */
    @Nullable
    public static PrimitiveSpec getSpec(Context context, int id) {
        switch (id) {
            case SPECIES:
                return getSpeciesSpec(context.getResources().getString(R.string.species));

            case BAIT_CATEGORY:
                return getBaitCategorySpec(context.getResources().getString(R.string.bait_category));

            case WATER_CLARITY:
                return getWaterClaritySpec(context.getResources().getString(R.string.water_clarity));

            case FISHING_METHODS:
                return getFishingMethodSpec(context.getResources().getString(R.string.fishing_method));

            case ANGLERS:
                return getAnglersSpec(context.getResources().getString(R.string.angler));
        }

        return null;
    }

    @NonNull
    private static PrimitiveSpec getSpeciesSpec(String name) {
        return new PrimitiveSpec(name, new PrimitiveSpec.InteractionListener() {
            @Override
            public ArrayList<UserDefineObject> onGetItems() {
                return Logbook.getSpecies();
            }

            @Override
            public UserDefineObject onClickItem(UUID id) {
                return Logbook.getSpecies(id);
            }

            @Override
            public boolean onAddItem(String name) {
                return Logbook.addSpecies(new Species(name));
            }

            @Override
            public boolean onRemoveItem(UUID id) {
                return Logbook.removeSpecies(id);
            }

            @Override
            public void onEditItem(UUID id, UserDefineObject newObj) {
                Logbook.editSpecies(id, new Species(newObj, true));
            }
        });
    }

    @NonNull
    private static PrimitiveSpec getBaitCategorySpec(String name) {
        return new PrimitiveSpec(name, new PrimitiveSpec.InteractionListener() {
            @Override
            public ArrayList<UserDefineObject> onGetItems() {
                return Logbook.getBaitCategories();
            }

            @Override
            public UserDefineObject onClickItem(UUID id) {
                return Logbook.getBaitCategory(id);
            }

            @Override
            public boolean onAddItem(String name) {
                return Logbook.addBaitCategory(new BaitCategory(name));
            }

            @Override
            public boolean onRemoveItem(UUID id) {
                return Logbook.removeBaitCategory(id);
            }

            @Override
            public void onEditItem(UUID id, UserDefineObject newObj) {
                Logbook.editBaitCategory(id, new BaitCategory(newObj, true));
            }
        });
    }

    @NonNull
    private static PrimitiveSpec getWaterClaritySpec(String name) {
        return new PrimitiveSpec(name, new PrimitiveSpec.InteractionListener() {
            @Override
            public ArrayList<UserDefineObject> onGetItems() {
                return Logbook.getWaterClarities();
            }

            @Override
            public UserDefineObject onClickItem(UUID id) {
                return Logbook.getWaterClarity(id);
            }

            @Override
            public boolean onAddItem(String name) {
                return Logbook.addWaterClarity(new WaterClarity(name));
            }

            @Override
            public boolean onRemoveItem(UUID id) {
                return Logbook.removeWaterClarity(id);
            }

            @Override
            public void onEditItem(UUID id, UserDefineObject newObj) {
                Logbook.editWaterClarity(id, new WaterClarity(newObj, true));
            }
        });
    }

    @NonNull
    private static PrimitiveSpec getFishingMethodSpec(String name) {
        return new PrimitiveSpec(name, new PrimitiveSpec.InteractionListener() {
            @Override
            public ArrayList<UserDefineObject> onGetItems() {
                return Logbook.getFishingMethods();
            }

            @Override
            public UserDefineObject onClickItem(UUID id) {
                return Logbook.getFishingMethod(id);
            }

            @Override
            public boolean onAddItem(String name) {
                return Logbook.addFishingMethod(new FishingMethod(name));
            }

            @Override
            public boolean onRemoveItem(UUID id) {
                return Logbook.removeFishingMethod(id);
            }

            @Override
            public void onEditItem(UUID id, UserDefineObject newObj) {
                Logbook.editFishingMethod(id, new FishingMethod(newObj, true));
            }
        });
    }

    @NonNull
    private static PrimitiveSpec getAnglersSpec(String name) {
        return new PrimitiveSpec(name, new PrimitiveSpec.InteractionListener() {
            @Override
            public ArrayList<UserDefineObject> onGetItems() {
                return Logbook.getAnglers();
            }

            @Override
            public UserDefineObject onClickItem(UUID id) {
                return Logbook.getAngler(id);
            }

            @Override
            public boolean onAddItem(String name) {
                return Logbook.addAngler(new Angler(name));
            }

            @Override
            public boolean onRemoveItem(UUID id) {
                return Logbook.removeAngler(id);
            }

            @Override
            public void onEditItem(UUID id, UserDefineObject newObj) {
                Logbook.editAngler(id, new Angler(newObj, true));
            }
        });
    }
}
