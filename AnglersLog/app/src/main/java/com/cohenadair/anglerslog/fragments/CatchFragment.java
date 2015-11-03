package com.cohenadair.anglerslog.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.views.ImageScrollView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single catch.
 */
public class CatchFragment extends DetailFragment {

    private Catch mCatch;
    private ArrayList<String> mCatchPhotos;

    private ImageScrollView mImageScrollView;
    private TextView mSpeciesTextView;
    private TextView mDateTextView;

    public CatchFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_catch, container, false);

        mImageScrollView = (ImageScrollView)view.findViewById(R.id.image_scroll_view);
        mImageScrollView.setInteractionListener(new ImageScrollView.InteractionListener() {
            @Override
            public void onImageClick(int position) {
                Intent intent = new Intent(getContext(), PhotoViewerActivity.class);
                intent.putStringArrayListExtra(PhotoViewerActivity.EXTRA_NAMES, mCatchPhotos);
                intent.putExtra(PhotoViewerActivity.EXTRA_CURRENT, position);
                startActivity(intent);
            }
        });

        mSpeciesTextView = (TextView)view.findViewById(R.id.species_text_view);
        mDateTextView = (TextView)view.findViewById(R.id.date_text_view);

        update(getRealActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity, UUID id) {
        if (isAttached()) {
            if (Logbook.getCatchCount() <= 0) {
                // TODO replace with "NoUserDefineView"
                mSpeciesTextView.setText("Select a catch to view it here.");
                mDateTextView.setText("");
            } else {
                setItemId(id);
                mCatch = Logbook.getCatch(id);

                if (mCatch != null) {
                    mCatchPhotos = mCatch.getPhotos();

                    mImageScrollView.setImages(mCatchPhotos);
                    mSpeciesTextView.setText(mCatch.getSpeciesAsString());
                    mDateTextView.setText(mCatch.getDateAsString());
                }
            }
        }
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        update(activity, activity.getSelectionId());
    }

}
