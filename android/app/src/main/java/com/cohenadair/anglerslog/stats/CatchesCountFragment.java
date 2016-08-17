package com.cohenadair.anglerslog.stats;

import android.graphics.Color;
import android.graphics.Point;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DefaultActivity;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.AlertUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.DisplayLabelView;
import com.cohenadair.anglerslog.views.PropertyDetailView;
import com.github.lzyzsd.randomcolor.RandomColor;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.data.PieEntry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.listener.ChartTouchListener;
import com.github.mikephil.charting.listener.OnChartGestureListener;
import com.github.mikephil.charting.listener.OnChartValueSelectedListener;

import java.util.ArrayList;
import java.util.List;

/**
 * A statistics fragment used to show the number of catches for a particular
 * {@link com.cohenadair.anglerslog.model.user_defines.UserDefineObject}.
 *
 * @author Cohen Adair
 */
public class CatchesCountFragment extends Fragment {

    private static final String ARG_STATS_ID = "arg_stats_id";

    private static final float SCREEN_HEIGHT_PERCENT = 0.575f;
    private static final float SLICE_SPACE = 2.5f;
    private static final float HOLE_RADIUS_PERCENT = 75.0f;
    private static final float TRASPARENT_HOLE_RADIUS_PERCENT = 80.0f;
    private static final float CENTER_TEXT_RADIUS_PERCENT = 95.0f;

    private StatsManager.StatsSpec mStatsSpec;

    private PieChart mPieChart;
    private DisplayLabelView mDetailView;
    private LinearLayout mExtendedView;
    private LinearLayout mExtendedWrapper;

    // used to disable the "deselect" feature
    private int mLastSelectedPosition = -1;

    public static CatchesCountFragment newInstance(int statsId) {
        CatchesCountFragment fragment = new CatchesCountFragment();

        Bundle args = new Bundle();
        args.putInt(ARG_STATS_ID, statsId);

        fragment.setArguments(args);
        return fragment;
    }

    public CatchesCountFragment() {

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catches_count, container, false);

        mStatsSpec = StatsManager.getStatsSpec(getContext(), getArguments().getInt(ARG_STATS_ID));
        if (mStatsSpec == null)
            return view;

        ((DefaultActivity)getActivity()).setActionBarTitle(mStatsSpec.getActivityTitle());

        mDetailView = (DisplayLabelView)view.findViewById(R.id.detail_view);
        mDetailView.setIconResource(mStatsSpec.getIconResource());

        mExtendedView = (LinearLayout)view.findViewById(R.id.extended_container);
        mExtendedWrapper = (LinearLayout)view.findViewById(R.id.extended_wrapper);
        ImageView extendedIcon = (ImageView)view.findViewById(R.id.extended_icon);
        extendedIcon.setImageResource(mStatsSpec.getExtendedIconResource());

        initPieChart(view);
        initTotalSpeciesView(view);
        initTotalCatchesView(view);

        return view;
    }

    private void initPieChart(View view) {
        mPieChart = (PieChart)view.findViewById(R.id.pie_chart);

        // set chart's height relative to the screen size
        // this can't be done in XML because it's a child of a ScrollView
        Point screenSize = Utils.getScreenSize(getContext());
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(screenSize.x, (int)(screenSize.y * SCREEN_HEIGHT_PERCENT));
        params.topMargin = getResources().getDimensionPixelOffset(R.dimen.margin_default);
        params.gravity = Gravity.CENTER_HORIZONTAL; // required for tablets in landscape
        mPieChart.setLayoutParams(params);

        ViewUtils.setVisibility(mPieChart, getTotalCatches() > 0);

        List<Stats.Quantity> items = mStatsSpec.getContent();
        List<PieEntry> entries = new ArrayList<>();
        int[] colors = new int[mStatsSpec.getContent().size()];

        for (int i = 0; i < items.size(); i ++) {
            Stats.Quantity item = items.get(i);
            entries.add(new PieEntry(item.getQuantity(), item.getName()));
            colors[i] = new RandomColor().randomColor();
        }

        PieDataSet pieDataSet = new PieDataSet(entries, "");
        pieDataSet.setColors(colors);
        pieDataSet.setSliceSpace(SLICE_SPACE);
        pieDataSet.setDrawValues(false);
        PieData pieData = new PieData(pieDataSet);

        mPieChart.setData(pieData);
        mPieChart.setHoleRadius(HOLE_RADIUS_PERCENT);
        mPieChart.setTransparentCircleRadius(TRASPARENT_HOLE_RADIUS_PERCENT);
        mPieChart.setCenterTextRadiusPercent(CENTER_TEXT_RADIUS_PERCENT);
        mPieChart.setDrawEntryLabels(false);
        mPieChart.setDrawCenterText(true);
        mPieChart.setDescription(""); // hide description
        mPieChart.setOnChartGestureListener(mPieChartListener);
        mPieChart.setOnChartValueSelectedListener(mPieChartValueSelectedListener);

        mPieChart.highlightValue(entries.size() - 1, 0, true);
        mPieChart.invalidate();
    }

    private void updatePieCenter(PieEntry entry, int position, boolean highlightSlice) {
        String label = entry.getLabel();
        String value = getCircleSubtitle((int)entry.getValue());

        SpannableStringBuilder builder = new SpannableStringBuilder()
                .append(label)
                .append("\n")
                .append(value);

        // style the title
        builder.setSpan(
                new AbsoluteSizeSpan(getResources().getDimensionPixelSize(R.dimen.font_large)),
                0,
                label.length(),
                Spannable.SPAN_INCLUSIVE_EXCLUSIVE
        );

        // style the subtitle
        builder.setSpan(
                new AbsoluteSizeSpan(getResources().getDimensionPixelSize(R.dimen.font_medium)),
                label.length(),
                label.length() + value.length() + 1,
                Spannable.SPAN_INCLUSIVE_EXCLUSIVE
        );

        builder.setSpan(
                new ForegroundColorSpan(Color.GRAY),
                label.length(),
                label.length() + value.length() + 1,
                Spannable.SPAN_INCLUSIVE_EXCLUSIVE
        );

        mPieChart.setCenterText(builder);

        if (highlightSlice) {
            mPieChart.highlightValue(position, 0, false);
        }

        updateMoreDetail(position);
        updateExtended(position);
    }

    private void updateMoreDetail(int position) {
        final UserDefineObject obj = mStatsSpec.getObject(position);

        if (obj == null) {
            ViewUtils.setVisibility(mDetailView, false);
            return;
        }

        mDetailView.setDetail(obj.getDisplayName());

        if (mStatsSpec.getLayoutSpecId() != -1)
            mDetailView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    startActivity(DetailFragmentActivity.getIntent(getContext(), mStatsSpec.getLayoutSpecId(), obj.getId()));
                }
            });
    }

    private void updateExtended(int position) {
        ArrayList<Stats.Quantity> content = mStatsSpec.getExtendedContent(position);
        int count = 0;
        mExtendedView.removeAllViews();

        for (Stats.Quantity item : content) {
            if (item.getQuantity() <= 0)
                continue;

            PropertyDetailView view = new PropertyDetailView(getContext());
            view.setProperty(item.getName());
            view.setDetail(Integer.toString(item.getQuantity()));

            mExtendedView.addView(view);
            count++;
        }

        ViewUtils.setVisibility(mExtendedWrapper, count > 0);
    }

    private PieEntry getEntryAtPosition(int position) {
        return mPieChart.getData().getDataSet().getEntryForIndex(position);
    }

    private String getCircleSubtitle(float value) {
        return Integer.toString((int) value) + " " + getResources().getString(R.string.drawer_catches);
    }

    private void onClickCenterCircle() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_list_item_1);
        ArrayList<Stats.Quantity> options = mStatsSpec.getContent();

        for (Stats.Quantity item : options)
            adapter.add(item.getName());

        AlertUtils.showSelection(getContext(), getChildFragmentManager(), adapter, new AlertUtils.OnSelectionDialogCallback() {
            @Override
            public void onSelect(int position) {
                updatePieCenter(getEntryAtPosition(position), position, true);
                mPieChart.invalidate();
            }
        });
    }

    private void initTotalSpeciesView(View view) {
        PropertyDetailView total = (PropertyDetailView)view.findViewById(R.id.total_view);
        total.setProperty(mStatsSpec.getUserDefineObjectName());
        total.setDetail(Integer.toString(mStatsSpec.getContent().size()));
    }

    private void initTotalCatchesView(View view) {
        PropertyDetailView totalCatches = (PropertyDetailView)view.findViewById(R.id.total_catches_view);
        totalCatches.setDetail(Integer.toString(getTotalCatches()));
    }

    private int getTotalCatches() {
        int total = 0;
        for (Stats.Quantity item : mStatsSpec.getContent())
            total += item.getQuantity();
        return total;
    }

    private OnChartValueSelectedListener mPieChartValueSelectedListener = new OnChartValueSelectedListener() {
        @Override
        public void onValueSelected(Entry e, Highlight h) {
            mLastSelectedPosition = (int)h.getX();
            PieEntry entry = (PieEntry) e;
            updatePieCenter(entry, mLastSelectedPosition, false);
        }

        @Override
        public void onNothingSelected() {
            // required so the slice isn't "deselected"
            if (mLastSelectedPosition != -1) {
                mPieChart.highlightValue(mLastSelectedPosition, 0, false);
            }
        }
    };

    private OnChartGestureListener mPieChartListener = new OnChartGestureListener() {
        @Override
        public void onChartGestureStart(MotionEvent me, ChartTouchListener.ChartGesture lastPerformedGesture) {

        }

        @Override
        public void onChartGestureEnd(MotionEvent me, ChartTouchListener.ChartGesture lastPerformedGesture) {

        }

        @Override
        public void onChartLongPressed(MotionEvent me) {

        }

        @Override
        public void onChartDoubleTapped(MotionEvent me) {

        }

        @Override
        public void onChartSingleTapped(MotionEvent me) {
            // get the coordinates of the point clicked and make sure it is in the center of the
            // chart
            float x = me.getX();
            float y = me.getY();

            float radius = mPieChart.getWidth() * (HOLE_RADIUS_PERCENT / 100) / 2;
            float centerX = (mPieChart.getX() + mPieChart.getWidth()) / 2;
            float centerY = (mPieChart.getY() + mPieChart.getHeight()) / 2;

            float distance = (float)Math.hypot(x - centerX, y - centerY);

            if (distance < (radius / 2)) {
                onClickCenterCircle();
            }
        }

        @Override
        public void onChartFling(MotionEvent me1, MotionEvent me2, float velocityX, float velocityY) {

        }

        @Override
        public void onChartScale(MotionEvent me, float scaleX, float scaleY) {

        }

        @Override
        public void onChartTranslate(MotionEvent me, float dX, float dY) {

        }
    };
}
