package com.ed_eureka.ed_eureka;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingViewsOptions;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdksample.initsdk.InitAuthSDKCallback;
import us.zoom.sdksample.initsdk.InitAuthSDKHelper;
import us.zoom.sdksample.ui.InitAuthSDKActivity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.PersistableBundle;
import org.jetbrains.annotations.NotNull;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.Toast;
import java.util.Map;
import java.util.*;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "package:us.zoom.sdksample.inmeetingfunction.customizedmeetingui";
    public static String EXTRA_MESSAGE = "EXTRA_MESSAGE";
    private ZoomSDK mZoomSDK;
    private EditText nameEdit;


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
       this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            String meetingNo = call.argument("zoomMeetingId");
                            String meetingPassword = call.argument("meetingPassword");
                            String userName = call.argument("userName");
                            openZoom(meetingNo, meetingPassword, userName);
                        }
                );
    }

    void openZoom(String id, String password, String userName){
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE);

        Intent intent = new Intent(this, InitAuthSDKActivity.class);
        intent.putExtra(EXTRA_MESSAGE,id);
        intent.putExtra("password", password);
        intent.putExtra("userName", userName);
        startActivity(intent);
    }
}
