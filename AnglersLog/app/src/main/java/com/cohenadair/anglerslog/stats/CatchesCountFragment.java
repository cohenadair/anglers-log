package com.cohenadair.anglerslog.stats;

import android.graphics.Point;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

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
 * @author Cohen Adair
 */
public class CatchesCountFragment extends Fragment {

    private static final String ARG_STATS_ID = "arg_stats_id";

    private StatsManager.StatsSpec mStatsSpec;

    private PieChartView mPieChartView;
    private TextView mPieCenterTitle;
    private TextView mPieCenterSubtitle;
    private DisplayLabelView mDetailView;
    private LinearLayout mExtendedView;
    private LinearLayout mExtendedWrapper;

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

        mDetailView = (DisplayLabelView)view.findViewById(R.id.detail_view);
        mDetailView.setIconResource(mStatsSpec.getIconResource());

        mExtendedView = (LinearLayout)view.findViewById(R.id.extended_container);
        mExtendedWrapper = (LinearLayout)view.findViewById(R.id.extended_wrapper);
        ImageView extendedIcon = (ImageView)view.findViewById(R.id.extended_icon);
        extendedIcon.setImageResource(mStatsSpec.getExtendedIconResource());

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

        ViewUtils.setVisibility(mPieChartView, getTotalCatches() > 0);

        List<SliceValue> values = new ArrayList<>();

        for (Stats.Quantity item : mStatsSpec.getContent())
            values.add(new SliceValue(item.getQuantity()).setLabel(item.getName()).setColor(new RandomColor().randomColor()));

        PieChartData data = new PieChartData();
        data.setValues(values);
        data.setHasCenterCircle(true);
        data.setCenterCircleScale((float) 0.775); // size of the center circle

        mPieChartView.setPieChartData(data);
        mPieChartView.setCircleFillRatio((float) 0.925); // percent of container
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
        int w = mPieChartView.getLayoutParams().width;
        int h = mPieChartView.getLayoutParams().height;

        // take the smaller of the width/height for tablet support
        int baseline = (h < w) ? h : w;

        int width =
                (int)(baseline * mPieChartView.getCircleFillRatio() * mPieChartView.getPieChartData().getCenterCircleScale() - // width of inner circle
                (getResources().getDimensionPixelOffset(R.dimen.margin_default) * 2) - // left and right margin of the chart
                (getResources().getDimensionPixelOffset(R.dimen.margin_half) * 2)); // left and right margin of the title TextView

        LinearLayout.LayoutParams linearParams =
                new LinearLayout.LayoutParams(width, LinearLayout.LayoutParams.WRAP_CONTENT);

        mPieCenterTitle.setLayoutParams(linearParams);

        // select the first item
        updatePieCenter(values.size() - 1, true);
    }

    private void updatePieCenter(int position, boolean select) {
        PieChartData data = mPieChartView.getPieChartData();
        SliceValue value = data.getValues().get(position);

        if (select)
            mPieChartView.selectValue(new SelectedValue(position, 0, SelectedValue.SelectedValueType.NONE));

        mPieCenterTitle.setText(new String(value.getLabelAsChars()));
        mPieCenterSubtitle.setText(getCircleSubtitle(value));

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

    private String getCircleSubtitle(SliceValue value) {
        return Integer.toString((int) value.getValue()) + " " + getResources().getString(R.string.drawer_catches);
    }

    private void onClickCenterCircle() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_list_item_1);
        ArrayList<Stats.Quantity> options = mStatsSpec.getContent();

        for (Stats.Quantity item : options)
            adapter.add(item.getName());

        AlertUtils.showSelection(getContext(), getChildFragmentManager(), adapter, new AlertUtils.OnSelectionDialogCallback() {
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
