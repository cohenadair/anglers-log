package com.cohenadair.anglerslog.baits;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.PartialListActivity;
import com.cohenadair.anglerslog.activities.PhotoViewerActivity;
import com.cohenadair.anglerslog.catches.CatchListManager;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.ListManager;
import com.cohenadair.anglerslog.utilities.ViewUtils;
import com.cohenadair.anglerslog.views.DisplayLabelView;
import com.cohenadair.anglerslog.views.ImageScrollView;
import com.cohenadair.anglerslog.views.PartialListView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single bait.
 * @author Cohen Adair
 */
public class BaitFragment extends DetailFragment {

    private Bait mBait;

    private ImageScrollView mImageScrollView;
    private DisplayLabelView mNameView;
    private DisplayLabelView mTypeView;
    private DisplayLabelView mColorView;
    private DisplayLabelView mSizeView;
    private DisplayLabelView mDescriptionView;
    private PartialListView mCatchesLayout;

    public BaitFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_bait, container, false);

        initImageView(view);
        setContainer((LinearLayout) view.findViewById(R.id.bait_container));

        mImageScrollView = (ImageScrollView)view.findViewById(R.id.image_scroll_view);
        mNameView = (DisplayLabelView)view.findViewById(R.id.name_view);
        mTypeView = (DisplayLabelView)view.findViewById(R.id.type_view);
        mColorView = (DisplayLabelView)view.findViewById(R.id.color_view);
        mSizeView = (DisplayLabelView)view.findViewById(R.id.size_view);
        mDescriptionView = (DisplayLabelView)view.findViewById(R.id.description_view);
        mCatchesLayout = (PartialListView)view.findViewById(R.id.catches_layout);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        clearActionBarTitle();

        // id can be null if in two-pane view and there are no baits
        if (id == null) {
            hide();
            return;
        }

        setItemId(id);
        mBait = Logbook.getBait(id);

        // mBait can be null if in tw-pane view and a bait was removed
        if (mBait == null) {
            hide();
            return;
        }

        show();

        String photo = mBait.getRandomPhoto();
        ArrayList<String> photos = new ArrayList<>();
        if (photo != null)
            photos.add(photo);
        mImageScrollView.setImages(photos);

        mNameView.setDetail(mBait.getName());
        mNameView.setLabel(mBait.getCategoryName());

        mTypeView.setDetail(getActivity().getResources().getString(mBait.getTypeName()));

        mColorView.setDetail(mBait.getColor());
        ViewUtils.setVisibility(mColorView, mBait.getColor() != null);

        mSizeView.setDetail(mBait.getSize());
        ViewUtils.setVisibility(mSizeView, mBait.getSize() != null);

        mDescriptionView.setDetail(mBait.getDescription());
        ViewUtils.setVisibility(mDescriptionView, mBait.getDescription() != null);

        updateCatchesList();
    }

    private void updateCatchesList() {
        ArrayList<UserDefineObject> catches = mBait.getCatches();
        boolean hasCatches = catches != null && catches.size() > 0;

        ViewUtils.setVisibility(mCatchesLayout, hasCatches);

        if (!hasCatches)
            return;

        mCatchesLayout.init(catches, new PartialListView.InteractionListener() {
            @Override
            public ListManager.Adapter onGetAdapter(ArrayList<UserDefineObject> items) {
                return new CatchListManager.Adapter(getContext(), items, true, new OnClickInterface() {
                    @Override
                    public void onClick(View view, UUID id) {
                        startDetailActivity(LayoutSpecManager.LAYOUT_CATCHES, id);
                    }
                });
            }

            @Override
            public void onClickAllButton(ArrayList<UserDefineObject> items) {
                Intent intent = PartialListActivity.getIntent(getContext(), mBait.getDisplayName(), LayoutSpecManager.LAYOUT_CATCHES, items);
                startActivity(intent);
            }
        });

        mCatchesLayout.setButtonText(R.string.all_catches);
    }

    private void initImageView(View view) {
        mImageScrollView = (ImageScrollView)view.findViewById(R.id.image_scroll_view);
        mImageScrollView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mBait.getPhotoCount() <= 0)
                    return;

                ArrayList<String> photos = new ArrayList<>();
                photos.add(mBait.getRandomPhoto());

                Intent intent = new Intent(getContext(), PhotoViewerActivity.class);
                intent.putStringArrayListExtra(PhotoViewerActivity.EXTRA_NAMES, photos);
                intent.putExtra(PhotoViewerActivity.EXTRA_CURRENT, 0);
                startActivity(intent);
            }
        });
    }

}
