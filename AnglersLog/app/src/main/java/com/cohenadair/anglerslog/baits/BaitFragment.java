package com.cohenadair.anglerslog.baits;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.views.PropertyDetailView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single bait.
 */
public class BaitFragment extends DetailFragment {

    private Bait mBait;

    private ImageView mImageView;
    private TextView mNameTextView;
    private TextView mCategoryTextView;
    private TextView mDescriptionTextView;
    private PropertyDetailView mTypeView;
    private PropertyDetailView mColorView;
    private PropertyDetailView mSizeView;

    public BaitFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_bait, container, false);

        initImageView(view);

        mNameTextView = (TextView)view.findViewById(R.id.bait_name);
        mCategoryTextView = (TextView)view.findViewById(R.id.bait_category);
        mDescriptionTextView = (TextView)view.findViewById(R.id.description_text_view);
        mTypeView = (PropertyDetailView)view.findViewById(R.id.type_view);
        mColorView = (PropertyDetailView)view.findViewById(R.id.color_view);
        mSizeView = (PropertyDetailView)view.findViewById(R.id.size_view);

        update(getRealActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity, UUID id) {
        if (isAttached()) {
            setItemId(id);
            mBait = Logbook.getBait(id);

            if (mBait == null)
                return;

            String photo = mBait.getRandomPhoto();
            if (photo != null) {
                int size = getRealActivity().getResources().getDimensionPixelSize(R.dimen.thumbnail_size);
                PhotoUtils.thumbnailToImageView(mImageView, PhotoUtils.privatePhotoPath(photo), size, R.drawable.no_catch_photo);
                mImageView.setVisibility(View.VISIBLE);
            }

            mNameTextView.setText(mBait.getName());
            mCategoryTextView.setText(mBait.getCategoryName());

            mTypeView.setDetail(getRealActivity().getResources().getString(mBait.getTypeName()));
            mTypeView.setVisibility(View.VISIBLE);

            if (mBait.getColor() != null) {
                mColorView.setDetail(mBait.getColor());
                mColorView.setVisibility(View.VISIBLE);
            }

            if (mBait.getSize() != null) {
                mSizeView.setDetail(mBait.getSize());
                mSizeView.setVisibility(View.VISIBLE);
            }

            if (mBait.getDescription() != null) {
                mDescriptionTextView.setText(mBait.getDescription());
                mDescriptionTextView.setVisibility(View.VISIBLE);
            }
        }
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        update(activity, activity.getSelectionId());
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
