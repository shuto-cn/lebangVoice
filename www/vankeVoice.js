var exec = require('cordova/exec');

var VankeVoice = {
	openVoice : function (success, error) {
	    exec(success, error, 'VankeVoice', 'openVoice', []);
	},
    closeVoice : function (success, error){
        exec(success, error, 'VankeVoice', 'closeVoice', []);
    },
    voiceToTextCallback : function (data) {
        console.debug('1111111111',JSON.parse(JSON.stringify(data)));
        cordova.fireDocumentEvent("VankeVoice.textData", JSON.parse(JSON.stringify(data)));

        // cordova.fireDocumentEvent("VankeVoice.textData", data);
    }

};

module.exports = VankeVoice;
