package com.cohenadair.anglerslog.activities;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.UUID;

/**
 * The DetailFragmentActivity is used to view a
 * {@link com.cohenadair.anglerslog.fragments.DetailFragment}.
 *
 * @author Cohen Adair
 */
public class DetailFragmentActivity extends DefaultActivity {

    public static final String EXTRA_LAYOUT_ID = "layout_spec_id";
    public static final String EXTRA_USER_DEFINE_ID = "user_define_id";

    private int mLayoutId = -1;
    private UUID mItemId;

    /**
     * Gets an Intent used to show a {@link DetailFragmentActivity}.
     *
     * @param context The context.
     * @param layoutSpecId See {@link LayoutSpecManager}.
     * @param userDefineObjectId The UUID of the object to display.
     * @return An Intent with required extras.
     */
    public static Intent getIntent(Context context, int layoutSpecId, UUID userDefineObjectId) {
        Intent intent = new Intent(context, DetailFragmentActivity.class);
        intent.putExtra(DetailFragmentActivity.EXTRA_TWO_PANE, Utils.isTwoPane(context));
        intent.putExtra(DetailFragmentActivity.EXTRA_LAYOUT_ID, layoutSpecId);
        intent.putExtra(DetailFragmentActivity.EXTRA_USER_DEFINE_ID, userDefineObjectId.toString());
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_default);
        initToolbar();
        initDialogWidth();

        Intent intent = getIntent();
        mLayoutId = intent.getIntExtra(EXTRA_LAYOUT_ID, -1);
        if (mLayoutId == -1)
            throw new RuntimeException("DetailFragmentActivity intent must include EXTRA_LAYOUT_ID.");

        String userDefineIdStr = intent.getStringExtra(EXTRA_USER_DEFINE_ID);
        if (userDefineIdStr == null)
            throw new RuntimeException("DetailFragmentActivity init must include EXTRA_USER_DEFINE_ID.");

        try {
            mItemId = UUID.fromString(userDefineIdStr);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            Utils.showToast(this, R.string.msg_error_showing_details);
            finish();
        }

        DetailFragment detailFragment = LayoutSpecManager.getDetailFragment(mLayoutId);
        if (detailFragment == null)
            throw new RuntimeException("Invalid layout id for DetailFragmentActivity.");

        detailFragment.setItemId(mItemId);

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, detailFragment)
                    .commit();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_share) {
            onClickShare(mItemId);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void onClickShare(UUID objId) {
        UserDefineObject obj = LayoutSpecManager.getObject(mLayoutId, objId);
        if (obj != null)
            startActivity(Intent.createChooser(obj.getShareIntent(this), null));
    }
}
