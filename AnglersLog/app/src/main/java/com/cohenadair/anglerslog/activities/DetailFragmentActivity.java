package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.os.Bundle;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;

import java.util.UUID;

/**
 * The DetailFragmentActivity is used to view a {@link com.cohenadair.anglerslog.fragments.DetailFragment}.
 * Created by Cohen Adair on 2015-12-12.
 */
public class DetailFragmentActivity extends DefaultActivity {

    public static final String EXTRA_LAYOUT_ID = "layout_spec_id";
    public static final String EXTRA_USER_DEFINE_ID = "user_define_id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_default);
        initToolbar();

        Intent intent = getIntent();
        int layoutSpecId = intent.getIntExtra(EXTRA_LAYOUT_ID, -1);
        if (layoutSpecId == -1)
            throw new RuntimeException("DetailFragmentActivity intent must include EXTRA_LAYOUT_ID.");

        String userDefineIdStr = intent.getStringExtra(EXTRA_USER_DEFINE_ID);
        if (userDefineIdStr == null)
            throw new RuntimeException("DetailFragmentActivity init must include EXTRA_USER_DEFINE_ID.");

        DetailFragment detailFragment = LayoutSpecManager.getDetailFragment(layoutSpecId);
        if (detailFragment == null)
            throw new RuntimeException("Invalid layout id for DetailFragmentActivity.");

        detailFragment.setItemId(UUID.fromString(userDefineIdStr));

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, detailFragment)
                    .commit();
    }

}
