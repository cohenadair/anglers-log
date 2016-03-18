package com.cohenadair.anglerslog.activities;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.fragments.ListPortionFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The CatchListPortionActivity is used to show a portion of a list.
 * @author Cohen Adair
 */
public class CatchListPortionActivity extends DefaultActivity {

    public static final String EXTRA_ITEMS = "extra_items";
    public static final String EXTRA_TITLE = "extra_title";

    public static Intent getIntent(Context context, String title, ArrayList<UserDefineObject> items) {
        Intent intent = new Intent(context, CatchListPortionActivity.class);
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

        ListPortionFragment fragment = new ListPortionFragment();
        fragment.setAdapter(new CatchListManager.Adapter(this, idsToCatches(), new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                startActivity(Utils.getDetailActivityIntent(CatchListPortionActivity.this, LayoutSpecManager.LAYOUT_CATCHES, id));
            }
        }));

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, fragment)
                    .commit();
    }

    private ArrayList<UserDefineObject> idsToCatches() {
        return UserDefineArrays.asObjectArray(
                getIntent().getStringArrayListExtra(EXTRA_ITEMS),
                new UserDefineArrays.OnConvertInterface() {
                    @Override
                    public UserDefineObject onGetObject(String idStr) {
                        return Logbook.getCatch(UUID.fromString(idStr));
                    }
                });
    }
}
