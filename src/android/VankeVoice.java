package com.vanke.cordova.voice;
import android.webkit.JavascriptInterface;
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

            //开启语音  callback(data) data为语音返回的文字
            callback("232321312323");

            return true;
        }else if(action.equals("closeVoice")){
            callbackContext.success();

            //关闭语音

            return true;
        }
        callbackContext.error("未找到对应方法");
        return false;
    }



    @JavascriptInterface
    public void callback(String data) {
        openVoice(String.format("window.VankeVoice.voiceToTextCallback(%s);", data));
    }

    private void openVoice(final String js) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:" + js);
            }
        });
    }
}
