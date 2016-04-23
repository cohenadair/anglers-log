package com.cohenadair.anglerslog.activities;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.PhotoViewerFragment;

import java.util.ArrayList;

public class PhotoViewerActivity extends AppCompatActivity {

    public static final String EXTRA_NAMES = "extra_names";
    public static final String EXTRA_CURRENT = "extra_current";

    public static Intent getIntent(Context context, ArrayList<String> photos, int position) {
        Intent intent = new Intent(context, PhotoViewerActivity.class);
        intent.putStringArrayListExtra(EXTRA_NAMES, photos);
        intent.putExtra(EXTRA_CURRENT, position);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_blank);

        PhotoViewerFragment fragment = new PhotoViewerFragment();
        fragment.setPhotoNames(getIntent().getStringArrayListExtra(EXTRA_NAMES));
        fragment.setStartIndex(getIntent().getIntExtra(EXTRA_CURRENT, 0));

        if (savedInstanceState == null)
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.container, fragment)
                    .commit();
    }
}
