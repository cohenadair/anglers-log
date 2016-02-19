package com.cohenadair.anglerslog.stats;

import android.graphics.Point;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DefaultActivity;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailView;
import com.cohenadair.anglerslog.views.PropertyDetailView;
import com.github.lzyzsd.randomcolor.RandomColor;

import java.util.ArrayList;
import java.util.List;

import lecho.lib.hellocharts.listener.PieChartOnValueSelectListener;
import lecho.lib.hellocharts.model.PieChartData;
import lecho.lib.hellocharts.model.SelectedValue;
import lecho.lib.hellocharts.model.SliceValue;
import lecho.lib.hellocharts.view.PieChartView;

/**
 * A statistics fragment used to show the number of catches for a particular
 * {@link com.cohenadair.anglerslog.model.user_defines.UserDefineObject}.
 *
 * Created by Cohen Adair on 2016-01-27.
 */
public class CatchesCountFragment extends Fragment {

    private static final String ARG_STATS_ID = "arg_stats_id";

    private StatsManager.StatsSpec mStatsSpec;

    private PieChartView mPieChartView;
    private TextView mPieCenterTitle;
    private TextView mPieCenterSubtitle;
    private MoreDetailView mMoreDetailView;

    /**
     * Used to capture click events on the center circle of the pie chart.
     */
    private boolean mClickedSlice = false;
    private boolean mIsFirst = true;

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

        mMoreDetailView = (MoreDetailView)view.findViewById(R.id.more_detail_view);
        Utils.toggleVisibility(mMoreDetailView, mStatsSpec.getCallbacks() != null);

        initPieChartCenter(view);
        initPieChart(view);
        initTotalSpeciesView(view);
        initTotalCatchesView(view);

        return view;
    }

    private void initPieChartCenter(View view) {
        mPieCenterTitle = (TextView)view.findViewById(R.id.pie_center_title);
        mPieCenterSubtitle = (TextView)view.findViewById(R.id.pie_center_subtitle);
    }

    private void initPieChart(View view) {
        mPieChartView = (PieChartView)view.findViewById(R.id.pie_chart);

        // set chart's height relative to the screen size
        // this can't be done in XML because it's a child of a ScrollView
        Point screenSize = Utils.getScreenSize(getContext());
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(screenSize.x, (int)(screenSize.y * 0.60));
        mPieChartView.setLayoutParams(params);

        Utils.toggleVisibility(mPieChartView, getTotalCatches() > 0);

        List<SliceValue> values = new ArrayList<>();

        for (Stats.Quantity item : mStatsSpec.getContent())
            values.add(new SliceValue(item.getQuantity()).setLabel(item.getName()).setColor(new RandomColor().randomColor()));

        PieChartData data = new PieChartData();
        data.setValues(values);
        data.setHasCenterCircle(true);
        data.setCenterCircleScale((float) 0.80); // size of the center circle

        mPieChartView.setPieChartData(data);
        mPieChartView.setCircleFillRatio((float) 0.95); // percent of container
        mPieChartView.setValueSelectionEnabled(true);
        mPieChartView.setChartRotationEnabled(false);
        mPieChartView.setClickable(true);

        mPieChartView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mClickedSlice)
                    onClickCenterCircle();

                mClickedSlice = false;
            }
        });

        mPieChartView.setOnValueTouchListener(new PieChartOnValueSelectListener() {
            @Override
            public void onValueSelected(int arcIndex, SliceValue value) {
                updatePieCenter(arcIndex, false);

                if (mIsFirst) {
                    mIsFirst = false;
                    return;
                }

                mClickedSlice = true;
            }

            @Override
            public void onValueDeselected() {

            }
        });

        // set the center circle's title size based on the rendered pie chart
        int width =
                (int)(mPieChartView.getLayoutParams().width * mPieChartView.getCircleFillRatio() * mPieChartView.getPieChartData().getCenterCircleScale() - // width of inner circle
                (getResources().getDimensionPixelOffset(R.dimen.margin_default) * 2) - // left and right margin of the chart
                (getResources().getDimensionPixelOffset(R.dimen.margin_half) * 2)); // left and right margin of the title TextView

        LinearLayout.LayoutParams linearParams =
                new LinearLayout.LayoutParams(width, LinearLayout.LayoutParams.WRAP_CONTENT);

        mPieCenterTitle.setLayoutParams(linearParams);

        // select the first item
        updatePieCenter(0, true);
    }

    private void updatePieCenter(int position, boolean select) {
        PieChartData data = mPieChartView.getPieChartData();
        SliceValue value = data.getValues().get(position);

        if (select)
            mPieChartView.selectValue(new SelectedValue(position, 0, SelectedValue.SelectedValueType.NONE));

        mPieCenterTitle.setText(new String(value.getLabelAsChars()));
        mPieCenterSubtitle.setText(getCircleSubtitle(value));

        updateMoreDetail(position, value);
    }

    private void updateMoreDetail(int position, SliceValue value) {
        final UserDefineObject obj = mStatsSpec.getObject(position);

        if (obj == null) {
            Utils.toggleVisibility(mMoreDetailView, false);
            return;
        }

        mMoreDetailView.setTitle(obj.getDisplayName());
        mMoreDetailView.setSubtitle(getCircleSubtitle(value));

        if (mStatsSpec.getLayoutSpecId() != -1)
            mMoreDetailView.setOnClickDetailButton(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    startActivity(Utils.getDetailActivityIntent(getContext(), mStatsSpec.getLayoutSpecId(), obj.getId()));
                }
            });
    }

    private String getCircleSubtitle(SliceValue value) {
        return Integer.toString((int) value.getValue()) + " " + getResources().getString(R.string.drawer_catches);
    }

    private void onClickCenterCircle() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(getContext(), android.R.layout.select_dialog_item);
        for (Stats.Quantity item : mStatsSpec.getContent())
            adapter.add(item.getName());

        Utils.showSelectionDialog(getContext(), adapter, new Utils.OnSelectionDialogCallback() {
            @Override
            public void onSelect(int position) {
                mPieChartView.invalidate();
                updatePieCenter(position, true);
                mClickedSlice = false;
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
}
