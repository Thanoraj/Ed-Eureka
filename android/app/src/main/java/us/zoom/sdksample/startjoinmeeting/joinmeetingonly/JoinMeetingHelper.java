package us.zoom.sdksample.startjoinmeeting.joinmeetingonly;

import android.content.Context;

import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingViewsOptions;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdksample.inmeetingfunction.zoommeetingui.ZoomMeetingUISettingHelper;

public class JoinMeetingHelper {
    private final static String TAG = "JoinMeetingHelper";

    private static JoinMeetingHelper mJoinMeetingHelper;

    private ZoomSDK mZoomSDK;

    private final static String DISPLAY_NAME = "ZoomUS_SDK";

    private JoinMeetingHelper() {
        mZoomSDK = ZoomSDK.getInstance();
    }

    public synchronized static JoinMeetingHelper getInstance() {
        mJoinMeetingHelper = new JoinMeetingHelper();
        return mJoinMeetingHelper;
    }

    public int joinMeetingWithNumber(Context context, String meetingNo, String meetingPassword) {
        int ret = -1;
        MeetingService meetingService = mZoomSDK.getMeetingService();
        if(meetingService == null) {
            return ret;
        }
        JoinMeetingOptions options = new JoinMeetingOptions();
        options.no_driving_mode = true;
        options.no_invite = true;
        options.no_titlebar = true;

        options.meeting_views_options = MeetingViewsOptions.NO_TEXT_PASSWORD
                + MeetingViewsOptions.NO_TEXT_MEETING_ID;


        //JoinMeetingOptions opts =ZoomMeetingUISettingHelper.getJoinMeetingOptions();

        JoinMeetingParams params = new JoinMeetingParams();


        params.displayName = DISPLAY_NAME;
        params.meetingNo = "";
        params.password = "meetingPassword";
        return meetingService.joinMeetingWithParams(context, params,options);
    }

    public int joinMeetingWithVanityId(Context context, String vanityId, String meetingPassword) {
        int ret = -1;
        MeetingService meetingService = mZoomSDK.getMeetingService();
        if(meetingService == null) {
            return ret;
        }
        JoinMeetingOptions options = new JoinMeetingOptions();
        options.no_driving_mode = true;
        options.no_invite = true;
        options.no_titlebar = true;
        options.meeting_views_options = MeetingViewsOptions.NO_TEXT_PASSWORD
                + MeetingViewsOptions.NO_TEXT_MEETING_ID;

        //JoinMeetingOptions opts =ZoomMeetingUISettingHelper.getJoinMeetingOptions();
        JoinMeetingParams params = new JoinMeetingParams();
        params.displayName = DISPLAY_NAME;
        params.vanityID = "vanityId";
        params.password = "meetingPassword";
        return meetingService.joinMeetingWithParams(context, params,options);
    }
}
