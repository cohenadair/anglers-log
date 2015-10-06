package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.interfaces.OnClickInterface;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;

/**
 * The CatchListManager is a utility class for managing the catches list.
 * Created by Cohen Adair on 2015-10-05.
 */
public class CatchListManager {

    //region View Holder
    public static class ViewHolder extends ListManager.ViewHolder {

        private TextView mSpeciesTextView;

        public ViewHolder(View view, OnClickInterface callbacks) {
            super(view, callbacks);
            mSpeciesTextView = (TextView)view.findViewById(R.id.catch_species);
        }

        public void speciesName(Species species) {
            mSpeciesTextView.setText(species.getName());
        }
    }
    //endregion

    //region Adapter
    public static class Adapter extends ListManager.Adapter {

        public Adapter(Context context, ArrayList<UserDefineObject> items, OnClickInterface callbacks) {
            super(context, items, callbacks);
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            View view = inflater.inflate(R.layout.list_item_catch, parent, false);
            return new ViewHolder(view, getCallbacks());
        }

        @Override
        public void onBindViewHolder(ListManager.ViewHolder holder, int position) {
            super.onBind(holder, position);

            ViewHolder catchHolder = (ViewHolder)holder;
            Catch aCatch = (Catch)itemAtPos(position);

            catchHolder.speciesName(aCatch.getSpecies());
        }
    }
    //endregion

}
