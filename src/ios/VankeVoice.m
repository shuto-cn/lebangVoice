/********* VankeVoice.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface VankeVoice : CDVPlugin {
// Member variables go here.
}

- (void)openVoice:(CDVInvokedUrlCommand*)command;
- (void)closeVoice:(CDVInvokedUrlCommand*)command;
+ (void)fireDocumentEvent:(NSString*)command;
    @end

static VankeVoice *SharedVankeVoicePlugin;

    @implementation VankeVoice

    //打开语音功能
- (void)openVoice:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if(!SharedVankeVoicePlugin){
        SharedVankeVoicePlugin = self;
    }

    //文字返回调用此方法
    [VankeVoice fireDocumentEvent:@"213123112"];



//未获取到语音返回具体原因
pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"getPictureFromCamera::未实现的方法!"];

[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//关闭语音功能
- (void)closeVoice:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;


//未关闭成功返回具体原因
pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"getPictureFromAlbum::未实现的方法!"];

[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//每次语音返回文字多次调用的方法
+(void)fireDocumentEvent:(NSString*)data{
if (SharedVankeVoicePlugin) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SharedVankeVoicePlugin.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('VankeVoice.textData','%s')",data]];
    });
    return;
    }
}
@end
