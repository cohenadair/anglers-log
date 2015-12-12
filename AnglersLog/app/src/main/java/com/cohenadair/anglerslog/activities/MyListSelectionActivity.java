package com.cohenadair.anglerslog.activities;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.View;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.utilities.LayoutSpec;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;

import java.util.UUID;

public class MyListSelectionActivity extends LayoutSpecActivity {

    public static final String EXTRA_SELECTED_ID = "extra_selected_id";
    public static final String EXTRA_LAYOUT_ID = "extra_layout_id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_list_selection);
        initToolbar();

        Intent intent = getIntent();
        int layoutId = intent.getIntExtra(EXTRA_LAYOUT_ID, -1);

        setLayoutSpec(LayoutSpecManager.layoutSpec(this, layoutId));

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, getMasterFragment())
                    .commit();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        finish();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        setActionBarTitle("");
    }

    @Override
    public OnClickInterface getOnMyListFragmentItemClick() {
        return new OnClickInterface() {
            @Override
            public void onClick(View view, UUID id) {
                LayoutSpec.OnSelectionListener listener = getLayoutSpec().getSelectionListener();
                if (listener != null)
                    listener.onSelect(id, new LayoutSpec.OnSelectionFinishedCallback() {
                        @Override
                        public void onFinish(UUID id) {
                            finishWithResult(id);
                        }
                    });
                else
                    finishWithResult(id);
            }
        };
    }

    @Override
    public void goToListManagerView() {
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.container, getManageFragment())
                .addToBackStack(null)
                .commit();

        setActionBarTitle(getViewTitle());
    }

    @Override
    public void goBack() {
        getSupportFragmentManager().popBackStack();
        setActionBarTitle("");
    }

    private void finishWithResult(UUID id) {
        Intent intent = new Intent();
        intent.putExtra(EXTRA_SELECTED_ID, id.toString());
        setResult(RESULT_OK, intent);
        finish();
    }
}
