package com.cohenadair.anglerslog.activities;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.baits.BaitListManager;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.fragments.PartialListFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.locations.LocationListManager;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The PartialListActivity is used to show a portion of a list.
 * @author Cohen Adair
 */
public class PartialListActivity extends DefaultActivity {

    public static final String EXTRA_LAYOUT = "extra_layout";
    public static final String EXTRA_ITEMS = "extra_items";
    public static final String EXTRA_TITLE = "extra_title";

    private int mLayoutId;

    public static Intent getIntent(Context context, String title, int layoutId, ArrayList<UserDefineObject> items) {
        Intent intent = new Intent(context, PartialListActivity.class);
        intent.putExtra(EXTRA_LAYOUT, layoutId);
        intent.putExtra(EXTRA_ITEMS, UserDefineArrays.asIdStringArray(items));
        intent.putExtra(EXTRA_TITLE, title);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_default);
        initToolbar();
        initDialogWidth();
        setActionBarTitle(getIntent().getStringExtra(EXTRA_TITLE));

        mLayoutId = getIntent().getIntExtra(EXTRA_LAYOUT, -1);
        if (mLayoutId == -1)
            throw new RuntimeException("EXTRA_LAYOUT cannot be -1");

        PartialListFragment fragment = new PartialListFragment();
        fragment.setAdapter(getAdapter());

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, fragment)
                    .commit();
    }

    /**
     * @see UserDefineArrays#objectsFromStringIds(ArrayList, UserDefineArrays.OnConvertInterface)
     */
    private ArrayList<UserDefineObject> idsToObjects(UserDefineArrays.OnConvertInterface onConvert) {
        return UserDefineArrays.objectsFromStringIds(getIntent().getStringArrayListExtra(EXTRA_ITEMS), onConvert);
    }

    /**
     * @see #idsToObjects(UserDefineArrays.OnConvertInterface)
     */
    private ArrayList<UserDefineObject> idsToCatches() {
        return idsToObjects(new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getCatch(UUID.fromString(idStr));
            }
        });
    }

    /**
     * @see #idsToObjects(UserDefineArrays.OnConvertInterface)
     */
    private ArrayList<UserDefineObject> idsToLocations() {
        return idsToObjects(new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getLocation(UUID.fromString(idStr));
            }
        });
    }

    /**
     * @see #idsToObjects(UserDefineArrays.OnConvertInterface)
     */
    private ArrayList<UserDefineObject> idsToBaits() {
        return idsToObjects(new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getBait(UUID.fromString(idStr));
            }
        });
    }

    @Nullable
    private ListManager.Adapter getAdapter() {
        ListManager.Adapter adapter = null;

        switch (mLayoutId) {
            case LayoutSpecManager.LAYOUT_CATCHES:
                adapter = new CatchListManager.Adapter(this, idsToCatches(), getOnClickInterface());
                break;

            case LayoutSpecManager.LAYOUT_LOCATIONS:
                adapter = new LocationListManager.Adapter(this, idsToLocations(), getOnClickInterface());
                break;

            case LayoutSpecManager.LAYOUT_BAITS:
                adapter = new BaitListManager.Adapter(this, idsToBaits(), getOnClickInterface());
                break;
        }

        // disable deleting/editing
        if (adapter != null) {
            adapter.setDisableLongClick(true);
        }

        return adapter;
    }

    @NonNull
    private OnClickInterface getOnClickInterface() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startActivity(DetailFragmentActivity.getIntent(PartialListActivity.this, mLayoutId, id));
            }
        };
    }
}
