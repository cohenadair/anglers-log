package com.cohenadair.anglerslog.utilities;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

/**
 * A controller object used to retrieve managing information for a primitive
 * {@link UserDefineObject} such as {@link Species}.
 *
 * Created by Cohen Adair on 2015-10-23.
 */
public class PrimitiveController {

    private static final int SPECIES = 0;

    // force singleton
    private PrimitiveController() { }

    /**
     * Gets a {@link PrimitiveSpec} object associated with a specified id.
     * @param id The id of the spec.
     * @return A PrimitiveSpec object associated with id or null if one doesn't exist.
     */
    @Nullable
    public static PrimitiveSpec getSpec(int id) {
        switch (id) {
            case SPECIES:
                return getSpeciesSpec();
        }

        return null;
    }

    @NonNull
    private static PrimitiveSpec getSpeciesSpec() {
        return new PrimitiveSpec("species", Logbook.getSpecies(), new PrimitiveSpec.InteractionListener() {
            @Override
            public UserDefineObject onClickItem(int position) {
                return Logbook.speciesAtPos(position);
            }

            @Override
            public boolean onAddItem(String name) {
                return Logbook.addSpecies(new Species(name));
            }

            @Override
            public void onEditItem(int position, String newName) {
                Logbook.editSpecies(position, newName);
            }

            @Override
            public void onConfirmDelete() {
                Logbook.cleanSpecies();
            }
        });
    }
}
