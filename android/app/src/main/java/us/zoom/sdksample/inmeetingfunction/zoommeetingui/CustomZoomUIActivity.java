package us.zoom.sdksample.inmeetingfunction.zoommeetingui;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.WindowManager;
import us.zoom.sdk.MeetingActivity;

public class CustomZoomUIActivity extends MeetingActivity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE);
    }

    @Override
    protected void onStartShare() {
        super.onStartShare();
    }

    @Override
    protected void onStopShare() {
        super.onStopShare();
    }

    @Override
    protected Bitmap getShareBitmap() {
        return super.getShareBitmap();
    }
}
