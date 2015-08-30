package com.cohenadair.anglerslog.activities;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.CatchFragment;
import com.cohenadair.anglerslog.fragments.CatchesFragment;
import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.utilities.Utilities;

import java.util.Calendar;
import java.util.Date;

public class MainActivity extends Activity implements CatchesFragment.OnListItemSelectedListener, FragmentManager.OnBackStackChangedListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setContentView(R.layout.main_layout);

        // initialize some dummy catches
        if (Logbook.getSharedLogbook().catchCount() <= 0)
            for (int i = 0; i < 12; i++) {
                Calendar calendar = Calendar.getInstance();
                calendar.set(Calendar.MONTH, i);
                Date aDate = calendar.getTime();

                Catch aCatch = new Catch(aDate);
                aCatch.setSpecies(new Species("Species " + i));

                Logbook.getSharedLogbook().addCatch(aCatch);
            }

        this.initFragments(savedInstanceState);
        this.initNavigation();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        this.getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }

        // pop the next item off the back stack
        if (id == android.R.id.home) {
            this.getFragmentManager().popBackStack();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void initFragments(Bundle savedInstanceState) {
        // add the catches fragment to the layout
        if (this.findViewById(R.id.main_container) != null) {
            // avoid multiple fragments stacked on top of one another
            if (savedInstanceState != null)
                return;

            CatchesFragment fragment = new CatchesFragment();
            fragment.setArguments(getIntent().getExtras());

            this.getFragmentManager().beginTransaction().add(R.id.main_container, fragment).commit();
        }
    }

    private CatchFragment findCatchFragment() {
        return (CatchFragment)this.getFragmentManager().findFragmentById(R.id.fragment_catch);
    }

    //region CatchesFragment.OnListItemSelectedListener interface
    public void onCatchSelected(int pos) {
        Logbook.getSharedLogbook().setCurrentCatchPos(pos);

        CatchFragment catchFragment = this.findCatchFragment();

        if (catchFragment != null && catchFragment.isVisible())
            catchFragment.updateCatch(pos);
        else {
            // show the single catch fragment
            catchFragment = new CatchFragment();

            FragmentTransaction transaction = this.getFragmentManager().beginTransaction();
            transaction.replace(R.id.main_container, catchFragment)
                       .addToBackStack(null)
                       .commit();
        }
    }
    //endregion

    //region Navigation
    public void initNavigation() {
        if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            this.getFragmentManager().addOnBackStackChangedListener(this);
            Utilities.handleDisplayBackButton(this);
        } else
            Utilities.handleDisplayBackButton(this, false); // remove back button for landscape
    }

    @Override
    public void onBackStackChanged() {
        Utilities.handleDisplayBackButton(this);
    }
    //endregion

}
