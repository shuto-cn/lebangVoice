package com.vanke.cordova.voice;

import android.app.Activity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;


import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.support.v4.content.FileProvider;
import android.util.Base64;
import android.text.TextUtils;
import java.util.ArrayList;
import java.util.List;
import java.lang.reflect.Method;
import org.apache.cordova.LOG;

public class VankeVoice extends CordovaPlugin {

    private Activity activity;
    private CordovaWebView webView;
    private static VankeVoice vankeVoice;
      private CallbackContext callbackContext;
    private  Class c;
        private  Object obj;
        private  Method method;

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
        this.callbackContext=callbackContext;
        if (action.equals("openVoice")) {
            callbackContext.success();
            vankeVoice = this;
            //开启语音操作
            startSpeech();
            return true;
        } else if (action.equals("closeVoice")) {
            callbackContext.success();
            //关闭语音
            stopSpeech();
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
        public void startSpeech(){
        LOG.d("LOG_TAG", "--startSpeech");
              try {
              c = Class.forName("com.lebang.activity.speech.WaterSpeechUtils");

              obj=c.getMethod("getInstance").invoke(null);

              if (obj!=null){

                  Method method=  c.getMethod("init", Context.class);

                  method.invoke(obj,new Object[]{activity});

                  c.getMethod("speechStart").invoke(obj);


              }

          } catch (Exception e) {
              callbackContext.error("未找到对应方法1");
              LOG.d("LOG_TAG", "--未找到对应方法1");
          }

      }

         public void stopSpeech(){
          LOG.d("LOG_TAG", "--stopSpeech");
              try {

                  if (obj!=null){

                      Method method1=  c.getMethod("speechCancel");

                      method1.invoke(obj);
                  }

              } catch (Exception e) {
                   callbackContext.error("未找到对应方法2");
                   LOG.d("LOG_TAG", "--未找到对应方法2");
              }
          }




}
