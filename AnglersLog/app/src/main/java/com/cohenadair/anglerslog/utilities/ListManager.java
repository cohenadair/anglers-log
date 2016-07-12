package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RatingBar;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.io.File;
import java.util.ArrayList;
import java.util.UUID;

import de.hdodenhof.circleimageview.CircleImageView;

/**
 * The ListManager is a utility class for managing the catches list. This class should never be
 * instantiated. Only the ViewHolder and Adapter classes should be used.
 *
 * @author Cohen Adair
 */
public class ListManager {

    //region View Holder
    public static abstract class ViewHolder extends ListSelectionManager.ViewHolder implements View.OnLongClickListener {

        private TextView mHeaderTextView;
        private CircleImageView mImageView;
        private TitleSubTitleView mTitleSubTitleView;
        private RatingBar mFavoriteStar;

        public interface OnToggleFavoriteStarListener {
            void onToggle(boolean isFavorite);
        }

        public ViewHolder(View view, Adapter adapter) {
            super(view, adapter);

            // header view and favorite star do not exist in the condensed layout, and items
            // shouldn't be editable via long click
            if (!getAdapter().isCondensed()) {
                view.setOnLongClickListener(this);
                mHeaderTextView = (TextView) view.findViewById(R.id.header_view);
                mFavoriteStar = (RatingBar) view.findViewById(R.id.favorite_star);
            }

            mImageView = (CircleImageView)view.findViewById(R.id.image_view);
            mTitleSubTitleView = (TitleSubTitleView)view.findViewById(R.id.content_view);
        }

        //region Getters & Setters
        public TextView getHeaderTextView() {
            return mHeaderTextView;
        }

        public CircleImageView getImageView() {
            return mImageView;
        }

        public TitleSubTitleView getTitleSubTitleView() {
            return mTitleSubTitleView;
        }

        public RatingBar getFavoriteStar() {
            return mFavoriteStar;
        }
        //endregion

        public void initForNormalLayout() {
            toggleHeader(false);
        }

        public void initForHeaderLayout() {
            toggleHeader(true);
        }

        public void initForSimpleLayout() {
            ViewUtils.setVisibility(mHeaderTextView, false);
            ViewUtils.setVisibility(mImageView, false);
            ViewUtils.setVisibility(mFavoriteStar, false);
        }

        @Override
        public boolean onLongClick(View view) {
            UserDefineObject obj = getObject();

            AlertUtils.showManageOptions(getContext(), obj.getName(), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    switch (which) {
                        case AlertUtils.MANAGE_ALERT_EDIT:
                            onItemEdit(getId());
                            break;

                        case AlertUtils.MANAGE_ALERT_DELETE:
                            onItemDelete(getId());
                            break;
                    }
                }
            });

            return true;
        }

        public void onItemEdit(UUID position) {
            ((DetailFragment.OnClickMenuListener)getContext()).onClickMenuEdit(position);
        }

        public void onItemDelete(UUID position) {
            ((DetailFragment.OnClickMenuListener)getContext()).onClickMenuTrash(position);
        }

        public Context getContext() {
            return getAdapter().getContext();
        }

        public void setHeaderText(String text) {
            if (mHeaderTextView == null)
                return;

            mHeaderTextView.setText(text);
        }

        public void setTitle(String title) {
            mTitleSubTitleView.setTitle(title);
        }

        public void setSubtitle(String subtitle) {
            mTitleSubTitleView.setSubtitle(subtitle);
        }

        public void setSubSubtitle(String subSubtitle) {
            mTitleSubTitleView.setSubSubtitle(subSubtitle);
        }

        public void setIsFavorite(boolean isFavorite) {
            if (mFavoriteStar == null)
                return;

            mFavoriteStar.setRating(isFavorite ? (float) 1.0 : (float) 0.0);
        }

        public void setImage(String fileName) {
            boolean fileExists = false;
            String randomPhotoPath = "";

            if (fileName != null)
                randomPhotoPath = PhotoUtils.privatePhotoPath(fileName);

            if (randomPhotoPath != null)
                fileExists = new File(randomPhotoPath).exists();

            if (fileExists) {
                int thumbSize = getContext().getResources().getDimensionPixelSize(R.dimen.size_list_thumb);
                PhotoUtils.thumbnailToImageView(mImageView, randomPhotoPath, thumbSize, R.drawable.placeholder_circle);
            } else
                mImageView.setImageResource(R.drawable.placeholder_circle);
        }

        public void setOnTouchFavoriteStarListener(final OnToggleFavoriteStarListener callbacks) {
            if (mFavoriteStar == null)
                return;

            mFavoriteStar.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    if (event.getAction() == MotionEvent.ACTION_UP) {
                        mFavoriteStar.setRating(mFavoriteStar.getRating() <= 0 ? (float) 1.0 : (float) 0.0);
                        callbacks.onToggle(mFavoriteStar.getRating() > 0);
                    }
                    return true;
                }
            });
        }

        private void toggleHeader(boolean showHeader) {
            ViewUtils.setVisibility(mHeaderTextView, showHeader);
            ViewUtils.setVisibility(mImageView, !showHeader);
            ViewUtils.setVisibility(mFavoriteStar, !showHeader);
            ViewUtils.setVisibility(mTitleSubTitleView, !showHeader);
        }

        @Override
        public Adapter getAdapter() {
            return (Adapter)super.getAdapter();
        }
    }
    //endregion

    //region Adapter
    public static abstract class Adapter extends ListSelectionManager.Adapter {

        private boolean mCondensed;

        /**
         * @see com.cohenadair.anglerslog.utilities.ListSelectionManager.Adapter
         */
        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean singleSelection, boolean multiSelection, OnClickInterface callbacks) {
            super(context, items, singleSelection, multiSelection, callbacks);
        }

        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean condensed, OnClickInterface callbacks) {
            this(context, items, false, false, callbacks);
            mCondensed = condensed;
        }

        public View inflateComplexItem(ViewGroup parent) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            return inflater.inflate(mCondensed ? R.layout.list_item_complex_condensed : R.layout.list_item_complex, parent, false);
        }

        public boolean isCondensed() {
            return mCondensed;
        }
    }
    //endregion
}
