package com.cohenadair.anglerslog.catches;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.views.ImageScrollView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single catch.
 */
public class CatchFragment extends DetailFragment {

    private Catch mCatch;
    private ArrayList<String> mCatchPhotos;

    private ImageScrollView mImageScrollView;
    private TitleSubTitleView mTitleView;

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

        mTitleView = (TitleSubTitleView)view.findViewById(R.id.title_view);

        update(getRealActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity, UUID id) {
        if (!isAttached())
            return;

        if (Logbook.getCatchCount() <= 0) {
            mTitleView.setVisibility(View.GONE);
        } else {
            setItemId(id);
            mCatch = Logbook.getCatch(id);

            if (mCatch != null) {
                mCatchPhotos = mCatch.getPhotos();

                mImageScrollView.setImages(mCatchPhotos);
                mTitleView.setTitle(mCatch.getSpeciesAsString());
                mTitleView.setSubtitle(mCatch.getDateAsString());
            }
        }
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        update(activity, activity.getSelectionId());
    }

}
