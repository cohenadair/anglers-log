package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.view.View;

import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.interfaces.OnClickManageMenuListener;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The ListManager is a utility class for managing the catches list. This class should never be
 * instantiated. Only the ViewHolder and Adapter classes should be used.
 * Created by Cohen Adair on 2015-10-05.
 */
public class ListManager {

    //region View Holder
    public static abstract class ViewHolder extends ListSelectionManager.ViewHolder implements View.OnLongClickListener {

        public ViewHolder(View view, Adapter adapter) {
            super(view, adapter);
            view.setOnLongClickListener(this);
        }

        @Override
        public boolean onLongClick(View view) {
            UserDefineObject obj = getObject();

            Utils.showManageAlert(getContext(), obj.getName(), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    switch (which) {
                        case Utils.MANAGE_ALERT_EDIT:
                            onItemEdit(getId());
                            break;

                        case Utils.MANAGE_ALERT_DELETE:
                            onItemDelete(getId());
                            break;
                    }
                }
            });

            return true;
        }

        public void onItemEdit(UUID position) {
            ((OnClickManageMenuListener)getContext()).onClickMenuEdit(position);
        }

        public void onItemDelete(UUID position) {
            ((OnClickManageMenuListener)getContext()).onClickMenuTrash(position);
        }

        public Context getContext() {
            return ((Adapter)getAdapter()).getContext();
        }

        public void updateView(View separator, int position) {
            // hide the separator for the last row
            Utils.toggleHidden(separator, position == getItemCount() - 1);
        }

    }
    //endregion

    //region Adapter
    public static abstract class Adapter extends ListSelectionManager.Adapter {

        private Context mContext;

        /**
         * @see com.cohenadair.anglerslog.utilities.ListSelectionManager.Adapter
         */
        public Adapter(Context context, ArrayList<UserDefineObject> items, boolean manageSelections, OnClickInterface callbacks) {
            super(items, manageSelections, callbacks);
            mContext = context;
        }

        public Context getContext() {
            return mContext;
        }

    }
    //endregion
}
