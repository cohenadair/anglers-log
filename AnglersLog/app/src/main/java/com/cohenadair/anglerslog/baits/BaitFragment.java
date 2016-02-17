package com.cohenadair.anglerslog.baits;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailLayout;
import com.cohenadair.anglerslog.views.PropertyDetailView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single bait.
 */
public class BaitFragment extends DetailFragment {

    private Bait mBait;

    private LinearLayout mContainer;
    private ImageView mImageView;
    private TitleSubTitleView mTitleSubTitleView;
    private TextView mDescriptionTextView;
    private TextView mNoCatchesTextView;
    private PropertyDetailView mTypeView;
    private PropertyDetailView mColorView;
    private PropertyDetailView mSizeView;
    private MoreDetailLayout mCatchesLayout;

    public BaitFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_bait, container, false);

        initImageView(view);

        mContainer = (LinearLayout)view.findViewById(R.id.bait_container);
        mTitleSubTitleView = (TitleSubTitleView)view.findViewById(R.id.title_view);
        mDescriptionTextView = (TextView)view.findViewById(R.id.description_text_view);
        mTypeView = (PropertyDetailView)view.findViewById(R.id.type_view);
        mColorView = (PropertyDetailView)view.findViewById(R.id.color_view);
        mSizeView = (PropertyDetailView)view.findViewById(R.id.size_view);
        mNoCatchesTextView = (TextView)view.findViewById(R.id.no_catches_text_view);
        mCatchesLayout = (MoreDetailLayout)view.findViewById(R.id.catches_layout);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        setActionBarTitle("");

        // id can be null if in two-pane view and there are no baits
        if (id == null) {
            mContainer.setVisibility(View.GONE);
            return;
        }

        setItemId(id);
        mBait = Logbook.getBait(id);

        // mBait can be null if in tw-pane view and a bait was removed
        if (mBait == null) {
            mContainer.setVisibility(View.GONE);
            return;
        }

        mContainer.setVisibility(View.VISIBLE);

        String photo = mBait.getRandomPhoto();
        if (photo != null) {
            int size = getActivity().getResources().getDimensionPixelSize(R.dimen.thumbnail_size);
            PhotoUtils.thumbnailToImageView(mImageView, PhotoUtils.privatePhotoPath(photo), size, R.drawable.no_catch_photo);
        }
        Utils.toggleVisibility(mImageView, photo != null);

        mTitleSubTitleView.setTitle(mBait.getName());
        mTitleSubTitleView.setSubtitle(mBait.getCategoryName());

        mTypeView.setDetail(getActivity().getResources().getString(mBait.getTypeName()));
        mTypeView.setVisibility(View.VISIBLE);

        mColorView.setDetail(mBait.getColor());
        Utils.toggleVisibility(mColorView, mBait.getColor() != null);

        mSizeView.setDetail(mBait.getSize());
        Utils.toggleVisibility(mSizeView, mBait.getSize() != null);

        mDescriptionTextView.setText(mBait.getDescription());
        Utils.toggleVisibility(mDescriptionTextView, mBait.getDescription() != null);

        updateCatchesList();
    }

    private void updateCatchesList() {
        ArrayList<UserDefineObject> catches = mBait.getCatches();
        boolean hasCatches = catches != null && catches.size() > 0;

        Utils.toggleVisibility(mNoCatchesTextView, !hasCatches);
        Utils.toggleVisibility(mCatchesLayout, hasCatches);

        if (!hasCatches)
            return;

        mCatchesLayout.init(null, catches, getCatchUpdateItemInterface(catches));
    }

    private void initImageView(View view) {
        mImageView = (ImageView)view.findViewById(R.id.bait_image_view);
        mImageView.setVisibility(View.GONE);
        mImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mBait.getPhotoCount() <= 0)
                    return;

                ArrayList<String> photos = new ArrayList<String>();
                photos.add(mBait.getRandomPhoto());

                Intent intent = new Intent(getContext(), PhotoViewerActivity.class);
                intent.putStringArrayListExtra(PhotoViewerActivity.EXTRA_NAMES, photos);
                intent.putExtra(PhotoViewerActivity.EXTRA_CURRENT, 0);
                startActivity(intent);
            }
        });
    }

}
