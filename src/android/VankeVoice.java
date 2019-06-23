package com.vanke.cordova.voice;

import android.app.Activity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

public class VankeVoice extends CordovaPlugin {

    private Activity activity;
    private CordovaWebView webView;
    private static VankeVoice vankeVoice;

    public VankeVoice() {
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        this.activity = cordova.getActivity();
        this.webView = webView;

    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (action.equals("openVoice")) {
            callbackContext.success();
            vankeVoice = this;

            //开启语音操作

            return true;
        } else if (action.equals("closeVoice")) {
            callbackContext.success();

            //关闭语音

            return true;
        }
        callbackContext.error("未找到对应方法");
        return false;
    }

    //调用返回的方法
    public static void openVoice(final String js) {
        VankeVoice.vankeVoice.activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                VankeVoice.vankeVoice.webView.loadUrl("javascript:" + String.format("window.VankeVoice.voiceToTextCallback('%s');", js));
            }
        });
    }
}
