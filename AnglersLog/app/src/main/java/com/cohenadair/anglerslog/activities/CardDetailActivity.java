package com.cohenadair.anglerslog.activities;

import android.os.Bundle;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.stats.StatsManager;

/**
 * The CardDetailActivity acts as a wrapper for a given fragment that displays the details of
 * a {@link com.cohenadair.anglerslog.views.DefaultCardView}.
 *
 * @author Cohen Adair
 */
public class CardDetailActivity extends DefaultActivity {

    public static final String EXTRA_STATS_ID = "extra_stats_id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_default);
        initToolbar();
        initDialogWidth();

        int statsId = getIntent().getIntExtra(EXTRA_STATS_ID, -1);
        if (statsId == -1)
            throw new RuntimeException("CardDetailActivity intent must include EXTRA_STATS_ID.");

        StatsManager.StatsSpec spec = StatsManager.getStatsSpec(this, statsId);

        if (savedInstanceState == null && spec != null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, spec.getDetailFragment())
                    .commit();
    }
}
