package com.cohenadair.anglerslog.stats;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DefaultActivity;
import com.cohenadair.anglerslog.model.Stats;
import com.cohenadair.anglerslog.utilities.Utils;
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

        initPieChart(view);
        initTotalSpeciesView(view);
        initTotalCatchesView(view);

        return view;
    }

    private void initPieChart(View view) {
        mPieChartView = (PieChartView)view.findViewById(R.id.pie_chart);

        List<SliceValue> values = new ArrayList<>();

        for (Stats.Quantity item : mStatsSpec.getContent())
            values.add(new SliceValue(item.getQuantity()).setLabel(item.getName()).setColor(new RandomColor().randomColor()));

        PieChartData data = new PieChartData();
        data.setValues(values);
        data.setHasCenterCircle(true);
        data.setCenterCircleScale((float) 0.75); // size of the center circle
        data.setCenterText1FontSize(fontSizeAsDp(R.dimen.font_large));
        data.setCenterText2FontSize(fontSizeAsDp(R.dimen.font_medium));
        data.setCenterText2Color(ContextCompat.getColor(getContext(), R.color.dark_grey));

        mPieChartView.setPieChartData(data);
        mPieChartView.setCircleFillRatio((float) 0.90); // percent of container
        mPieChartView.setValueSelectionEnabled(true);
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

        // select the first item
        updatePieCenter(0, true);
    }

    private void updatePieCenter(int position, boolean select) {
        PieChartData data = mPieChartView.getPieChartData();
        SliceValue value = data.getValues().get(position);

        if (select)
            mPieChartView.selectValue(new SelectedValue(position, 0, SelectedValue.SelectedValueType.NONE));

        data.setCenterText1(new String(value.getLabelAsChars()));
        data.setCenterText2(Integer.toString((int) value.getValue()) + " " + getResources().getString(R.string.drawer_catches));
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

        int total = 0;
        for (Stats.Quantity item : mStatsSpec.getContent())
            total += item.getQuantity();

        totalCatches.setDetail(Integer.toString(total));
    }

    private int fontSizeAsDp(int resId) {
        return (int)(getResources().getDimensionPixelOffset(resId) / getResources().getDisplayMetrics().density);
    }
}
