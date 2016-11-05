package com.example.baidupush;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;
import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushMessageReceiver;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import java.util.List;

/**
 * Created by qiepeipei on 16/8/13.
 */
public class MyPushMessageReceiver extends PushMessageReceiver {

    private String NAME = "RNBaiduPush.MyPushMessageReceiver";
    @Override
    public void onBind(Context context, int errorCode, String appid,
                       String userId, String channelId, String requestId) {

        /*String responseString = "{errorCode:" + errorCode + ", appid:" + appid
                + ",userId:" + userId + ", channelId:" + channelId
                + ", requestId:" + requestId+"}";
        Log.d(NAME, responseString);*/
        WritableMap params = Arguments.createMap();
        params.putInt("error_code", errorCode);
        params.putString("appid", appid);
        params.putString("user_id", userId);
        params.putString("channel_id", channelId);
        Log.d(NAME, "绑定成功");
        PushModule.myPush.sendState(errorCode,1,params);
    }

    @Override
    public void onUnbind(Context context, int errorCode, String s) {
        Log.d(NAME, "onUnbind");
        WritableMap params = Arguments.createMap();
        params.putInt("error_code", errorCode);
        params.putString("msg", s);
        PushModule.myPush.sendState(errorCode,2,params);
    }

    @Override
    public void onSetTags(Context context, int errorCode, List<String> list, List<String> list1, String s) {
        Log.d(NAME, "onSetTags");

        WritableMap params = Arguments.createMap();
        params.putInt("error_code", errorCode);
        //params.putInt("list", list);
        //params.putInt("list1", list1);
        params.putString("msg", s);
        PushModule.myPush.sendState(errorCode,3,params);
    }

    @Override
    public void onDelTags(Context context, int errorCode, List<String> list, List<String> list1, String s) {
        Log.d(NAME, "onDelTags");
        WritableMap params = Arguments.createMap();
        params.putInt("error_code", errorCode);
        PushModule.myPush.sendState(errorCode,4,params);
    }

    @Override
    public void onListTags(Context context, int errorCode, List<String> list, String s) {
        WritableMap params = Arguments.createMap();
        params.putInt("error_code", errorCode);
        WritableArray arr = new WritableNativeArray();
        for (String tag : list) {
            arr.pushString(tag);
        }
        params.putArray("tags",arr);
        PushModule.myPush.sendState(errorCode,5,params);
    }

    //接收透传消息
    /*
    *   context 上下文
        message 推送的消息
        customContentString 自定义内容，为空或者json字符串
    * */
    @Override
    public void onMessage(Context context, String message, String customContentString) {
        Log.d(NAME, "收到透传消息");

        PushModule.myPush.sendPenetrateMsg(message,customContentString);

    }

    /*接收通知点击的函数

    *   context 上下文
        title 推送的通知的标题
        description 推送的通知的描述
        customContentString 自定义内容，为空或者json字符串
    * */
    @Override
    public void onNotificationClicked(Context context, String title, String description, String customContentString) {
        Log.d(NAME, "已点击通知栏");
        String key = "push_clicked";
        String json = "{\"title\":\""+title+"\",\"desc\":\""+description+"\",\"custom\":\""+customContentString+"\"}";
        //Log.d(NAME, "shareStorage: key="+key+"   value="+json);
        String SHARED_NAME = "wit_player_shared_preferences";
        //SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences sp = context.getSharedPreferences(SHARED_NAME, Context.MODE_PRIVATE);
        Editor editor = sp.edit();
        editor.putString(key, json);
        editor.commit();
        //SharedHandler.getInstance().putExtra(key, json);

        String packageName = context.getApplicationContext().getPackageName();
        Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        context.startActivity(launchIntent);
        //PushModule.myPush.sendPushMsg(title,description);
    }

    /*接收通知到达的函数
    *
    *   context 上下文
        title 推送的通知的标题
        description 推送的通知的描述
        customContentString 自定义内容，为空或者json字符串

    * */

    @Override
    public void onNotificationArrived(Context context, String title, String description, String customContentString) {

        Log.d(NAME, "收到通知消息");


    }
}
