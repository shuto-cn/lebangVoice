本项目是调用lebang语音功能的插件，项目本身依赖于Lebang项目
安装方法
```bash
ionic cordova plugin add https://github.com/shuto-cn/lebangVoice.git
```
使用方法：

```javascript
if(VankeVoice){
    VankeVoice.openVoice(function (msg) {
        console.log("getPictureFromCamera",msg);
    },function (err) {
        console.error("getPictureFromCamera",err);
    });
    VankeVoice.closeVoice(8,function (msg) {
        console.log("getPictureFromAlbum",msg);
    },function (err) {
        console.error("getPictureFromAlbum",err);
    });
}
```
