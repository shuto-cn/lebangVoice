/********* VankeVoice.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "iflyMSC/iflyMSC.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"
#import <AVFoundation/AVFoundation.h>

@interface VankeVoice : CDVPlugin<UITextViewDelegate, AVAudioRecorderDelegate,
IFlySpeechRecognizerDelegate>
@property (nonatomic, assign) BOOL isAuthorized;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, assign) BOOL shouldContinueRecognize;//是否应该继续识别（判断用户是否取消了识别）
@property (nonatomic, strong) NSMutableString *resultText;//拼接结果
@property (nonatomic, strong) NSString *callbackId;

- (void)openVoice:(CDVInvokedUrlCommand*)command;
- (void)closeVoice:(CDVInvokedUrlCommand*)command;
- (void)fireDocumentEvent:(NSString*)command;
@end

@implementation VankeVoice
#pragma mark - life cycle
- (void)dealloc
{
    [self cancelListenWrite];
}

#pragma mark - authorization
-(void)checkAuthorizeStatus:(void(^)(BOOL))authorizeBlcok
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            
            [session requestRecordPermission:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorizeBlcok(granted);
                });
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            NSLog(@"请用户去设置开启权限");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"访问受限"
                                                            message:@"请前往“设置”中允许“助英台”访问您的麦克风"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"设置", nil];
            [alert show];
            authorizeBlcok(NO);
        }
            break;
        default:
            authorizeBlcok(YES);
            break;
    }
}

#pragma mark - open/close method
//打开语音功能
- (void)openVoice:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    
    //    if(!SharedVankeVoicePlugin){
    //        SharedVankeVoicePlugin = self;
    //    }
    
    [self changeVoiceRecognizerState:YES];
}

//关闭语音功能
- (void)closeVoice:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    
    [self changeVoiceRecognizerState:NO];
}

//每次语音返回文字多次调用的方法
-(void)fireDocumentEvent:(NSString*)data{
    //    if (SharedVankeVoicePlugin) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('VankeVoice.textData','%@')",data]];
    });
    return;
    //    }
}

-(void)changeVoiceRecognizerState:(BOOL)isOpen
{
    [self checkAuthorizeStatus:^(BOOL authorized) {
        if (authorized) {
            
            if (isOpen) {
                self.shouldContinueRecognize = YES;
                [self.iFlySpeechRecognizer startListening];
            }
            else
            {
                self.shouldContinueRecognize = NO;
                [self.iFlySpeechRecognizer stopListening];
            }
        }
        else
        {
            [self faildCallBack:@"您拒绝了助英台访问麦克风权限"];
        }
    }];
}

- (void)cancelListenWrite
{
    if (_iFlySpeechRecognizer) {
        [_iFlySpeechRecognizer stopListening];
        [_iFlySpeechRecognizer cancel];
    }
}

-(void)successCallBack:(NSString *)recognizedString
{
    [self fireDocumentEvent:recognizedString];
}

-(void)faildCallBack:(NSString *)failedReasonStr
{
    //未关闭成功返回具体原因
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:failedReasonStr];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

#pragma mark - IFlySpeechRecognizerDelegate、alterViewDelegate
// 识别结果返回代理
/*
 在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。 使用results的示例如下： - (void) onResults:(NSArray *) results{ NSMutableString *result = [[NSMutableString alloc] init]; NSDictionary *dic = [results objectAtIndex:0]; for (NSString *key in dic){ [result appendFormat:"%",key];//合并结果 } }
 */
- (void)onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@", key];
    }
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    NSLog(@"单次听写结果：%@",  resultFromJson);
    [self.resultText appendString:resultFromJson];
    
    [self fireDocumentEvent:resultFromJson];
    
    if (isLast){
        NSLog(@"听写结果：%@",  self.resultText);
    }
}

// 识别会话结束返回代理
- (void)onCompleted:(IFlySpeechError *)error
{
    if (error.errorCode!=0&&error.errorCode!=10114) {
        [self faildCallBack:error.errorDesc];
    }
    else
    {
        if (self.shouldContinueRecognize) {
            [self.iFlySpeechRecognizer startListening];
        }
    }
}

// 停止录音回调
- (void)onEndOfSpeech
{
    NSLog(@"IFly Listen End of Speech");
}

// 开始录音回调
- (void)onBeginOfSpeech
{
    NSLog(@"IFly Listen Begin of Speech");
}

//// 音量回调
//- (void)onVolumeChanged:(int)volume
//{
//
//}
// 会话取消回调
- (void)onCancel
{
    NSLog(@"IFly Listen Cancel");
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [AppUtility openApplicationSetting];
}


#pragma mark - getter/setter
-(IFlySpeechRecognizer *)iFlySpeechRecognizer
{
    if(!_iFlySpeechRecognizer)
    {
        // 创建语音识别对象
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        // 设置识别参数
        
        // 设置为听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        //         asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
        [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        _iFlySpeechRecognizer.delegate = self;
        
        IATConfig *instance = [IATConfig sharedInstance];
        // 设置最长录音时间
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        // 设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        // 设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        // 网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        // 设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        // 设置语言
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        // 设置方言
        [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        // 设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
    return _iFlySpeechRecognizer;
}

-(NSMutableString *)resultText
{
    if (!_resultText) {
        _resultText = [NSMutableString string];
    }
    return _resultText;
}
@end
