#!/bin/bash
cd /home/volumio/Install_appearance

# copy css files for additional styles
[ ! -d "backup/http" ] && mkdir -p backup/http
www3=/volumio/http/www3/styles
ID=$(ls ${www3}/app-??????????.css)
ID=${ID#*app-}
ID=${ID%.*}

if [ -d "$ID" ]; then 
	[ ! -f "${www3}/app-${ID}_1.css" ] && cp ${www3}/app-${ID}.css backup/http 
	pushd $ID
	cp -f app-${ID}_0.css $www3
	cp -f app-${ID}_1.css $www3
	cp -f app-${ID}_2.css $www3
	popd 
else
	echo No matching version - no installation possible!!
	exit
fi

# add new content to config.json
[ ! -d "backup/appearance" ] && mkdir backup/appearance
conf=/volumio/app/plugins/miscellanea/appearance/config.json
if ! grep -q 'ContempMod' $conf; then
	cp $conf backup/appearance
	sed -i '/"language"/i\
  "ContempMod":{"value":"0","type":"string"},\
  "forecolor":{"value":"84,198,136","type":"string"},\
  "forecolor_title":{"value":"green","type":"string"},\
  "bgdarkness":{"value":"0.4","type":"string"},\
  "ftopacity":{"value":"0.4","type":"string"},\
  "fthide":{"value":false,"type":"boolean"},\
  "headerbackdrop":{"value":true,"type":"boolean"},\
  "aadim":{"value":"0","type":"number"},\
  "aaspace":{"value":"2","type":"number"},\
  "border":{"value":true,"type":"boolean"},\
  "bordercorner":{"value":true,"type":"boolean"},\
  "bordercolor":{"value":"255,255,255","type":"string"},\
  "bordercolor_title":{"value":"white","type":"string"},\
  "aashadow":{"value":true,"type":"boolean"},\
  "textwrap":{"value":false,"type":"boolean"},\
  "tinfoY":{"value":"8","type":"number"},\
  "tinfoY2":{"value":"12","type":"number"},\
  "tinfoY3":{"value":"15","type":"number"},\
  "title":{"value":"16","type":"number"},\
  "title2":{"value":"18","type":"number"},\
  "title3":{"value":"24","type":"number"},\
  "artist":{"value":"14","type":"number"},\
  "artist2":{"value":"16","type":"number"},\
  "artist3":{"value":"18","type":"number"},\
  "srate":{"value":"14","type":"number"},\
  "srate2":{"value":"16","type":"number"},\
  "srate3":{"value":"24","type":"number"},\
  "sratespace":{"value":"5","type":"number"},\
  "sratespace2":{"value":"10","type":"number"},\
  "sratespace3":{"value":"15","type":"number"},\
  "buttons":{"value":"0","type":"number"},\
  "resolution":{"value":"0","type":"string"},\
  "resolution_title":{"value":"width < 1200px","type":"string"},' $conf
fi

# add new content UIConfig.json
UI=/volumio/app/plugins/miscellanea/appearance/UIConfig.json
if ! grep -q 'forecolor' $UI; then cp $UI backup/appearance; fi

sed -i '/"id": "volumio3_ui"/,$d' $UI
sed -i '$r UIConfig_add.json' $UI
sed -i '/--InsertColorOptions--/r colors.json' $UI
sed -i '/--InsertColorOptions--/d' $UI
sed -i '/--InsertOpacities--/r opacities.json' $UI
sed -i '/--InsertOpacities--/d' $UI

# patch appearance index.js to read new UI values
AP=/volumio/app/plugins/miscellanea/appearance/index.js
if ! grep -q '//-----> add read new variables' $AP; then
	cp $AP backup/appearance
else
	sed -n -i '/-----> add read new variables/,/<----- end add/!p' $AP
fi

if ! grep -q '//-----> add variable' $AP; then
	sed -i '/use strict'\'';/a\
\
//-----> add variable for css file\
var cssfile = "/volumio/http/www3/styles/app-'"$ID"'";\
var aart = new Array(2);\
var tinfo = new Array(8);\
var tinfo2 = new Array(18);\
//<-----' $AP
fi

sed -i '/uiLayoutSettingLabel);/a\
//-----> add read new variables and set UI\
    var ContempMod = config.get("ContempMod");\
    if (ContempMod != undefined && ContempMod != "0") {\
        if (ContempMod < "3") {\
            self.configManager.setUIConfigParam(uiconf, "sections[3].hidden", false);\
            self.configManager.setUIConfigParam(uiconf, "sections[4].hidden", false);\
        }\
        if (ContempMod == "1") {\
            self.configManager.setUIConfigParam(uiconf, "sections[5].hidden", false);\
        }\
        if (ContempMod == "2") {\
            self.configManager.setUIConfigParam(uiconf, "sections[6].hidden", false);\
            self.configManager.setUIConfigParam(uiconf, "sections[3].content[4].hidden", false);\
        }\
        self.configManager.setUIConfigParam(uiconf, "sections[2].content[0].value.value", ContempMod);\
        self.configManager.setUIConfigParam(uiconf, "sections[2].content[0].value.label", "Contemporary mod " + ContempMod);\
    }\
\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[0].value.value", config.get("forecolor"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[0].value.label", config.get("forecolor_title"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[1].value.value", config.get("bgdarkness"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[1].value.label", config.get("bgdarkness"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[2].value.value", config.get("ftopacity"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[2].value.label", config.get("ftopacity"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[3].value", config.get("fthide"));\
    self.configManager.setUIConfigParam(uiconf, "sections[3].content[4].value", config.get("headerbackdrop"));\
\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[0].value", parseInt(config.get("aadim"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[1].value", parseInt(config.get("aaspace"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[2].value", config.get("border"));\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[3].value.value", config.get("bordercolor"));\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[3].value.label", config.get("bordercolor_title"));\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[4].value", config.get("bordercorner"));\
    self.configManager.setUIConfigParam(uiconf, "sections[4].content[5].value", config.get("aashadow"));\
    for (var i = 0; i < aart.length ; i++) {\
      aart[i] = [uiconf.sections[4].content[i].attributes[2].min,\
      uiconf.sections[4].content[i].attributes[3].max,\
      uiconf.sections[4].content[i].attributes[0].placeholder];\
    }\
\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[0].value", parseInt(config.get("buttons"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[1].value", config.get("textwrap"));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[2].value", parseInt(config.get("tinfoY"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[3].value", parseInt(config.get("title"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[4].value", parseInt(config.get("title2"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[5].value", parseInt(config.get("artist"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[6].value", parseInt(config.get("srate"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[5].content[7].value", parseInt(config.get("sratespace"),10));\
    for (var i = 0; i < tinfo.length ; i++) {\
      if (i != 1) {\
        tinfo[i] = [uiconf.sections[5].content[i].attributes[2].min,\
        uiconf.sections[5].content[i].attributes[3].max,\
        uiconf.sections[5].content[i].attributes[0].placeholder];\
      }\
    }\
\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[0].value", parseInt(config.get("buttons"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[1].value", config.get("textwrap"));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[2].value.value", config.get("resolution"));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[2].value.label", config.get("resolution_title"));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[3].value", parseInt(config.get("tinfoY"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[4].value", parseInt(config.get("title"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[5].value", parseInt(config.get("artist"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[6].value", parseInt(config.get("srate"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[7].value", parseInt(config.get("sratespace"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[8].value", parseInt(config.get("tinfoY2"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[9].value", parseInt(config.get("title2"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[10].value", parseInt(config.get("artist2"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[11].value", parseInt(config.get("srate2"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[12].value", parseInt(config.get("sratespace2"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[13].value", parseInt(config.get("tinfoY3"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[14].value", parseInt(config.get("title3"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[15].value", parseInt(config.get("artist3"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[16].value", parseInt(config.get("srate3"),10));\
    self.configManager.setUIConfigParam(uiconf, "sections[6].content[17].value", parseInt(config.get("sratespace3"),10));\
    for (var i = 0; i < tinfo2.length ; i++) {\
      if (i != 1 && i != 2) {\
        tinfo2[i] = [uiconf.sections[6].content[i].attributes[2].min,\
        uiconf.sections[6].content[i].attributes[3].max,\
        uiconf.sections[6].content[i].attributes[0].placeholder];\
      }\
    }\
//<----- end add' $AP	

# patch appearance index.js to write new UI values
sed -i '/volumioAppearance.prototype.setVolumio3UI/,/volumioAppearance.prototype.sendSizeErrorToasMessage/{//!d}' $AP
sed -i '/volumioAppearance.prototype.setVolumio3UI/a\
  var self = this;\
\
  // conteporary original\
  if (data && data.volumio3_ui.value == "0") {\
    config.set("ContempMod", "0"); // reset modification\
    try {\
      execSync("/bin/cp " + cssfile + "_0.css " + cssfile + ".css"); // copy the original css\
      process.env.VOLUMIO_3_UI = "true";\
      self.commandRouter.reloadUi();\
      execSync("/bin/rm /data/volumio2ui");\
    } catch (e) {\
      self.logger.error(e);\
    }\
  // conteporary mod 1/2\
  } else if (data.volumio3_ui.value == "1" || data.volumio3_ui.value == "2") {\
    config.set("ContempMod", data.volumio3_ui.value); // save modification\
    try {\
      execSync("/bin/cp " + cssfile + "_" + data.volumio3_ui.value + ".css " + cssfile + ".css");\
      //execSync("/usr/bin/touch /data/volumio2ui");\
      process.env.VOLUMIO_3_UI = "true";\
      self.commandRouter.reloadUi();\
      execSync("/bin/rm /data/volumio2ui");\
    } catch (e) {\
      self.logger.error(e);\
    }\
  // classic interface\
  } else {\
    config.set("ContempMod", "0"); // reset modification\
    try {\
      execSync("/bin/cp " + cssfile + "_0.css " + cssfile + ".css"); // copy the original css\
      execSync("/usr/bin/touch /data/volumio2ui");\
      process.env.VOLUMIO_3_UI = "false";\
      self.commandRouter.reloadUi();\
    } catch (e) {\
      self.logger.error(e);\
    }\
  }\
};\
\
volumioAppearance.prototype.setGlobalModUI = function (data) {\
  var self = this;\
\
    try {\
      config.set("forecolor", data.forecolor.value);\
      config.set("forecolor_title", data.forecolor.label);\
      execSync("bin/sed -i '\''/GUI_ID: 100/!b;n;c--forecolor: " + data.forecolor.value + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 100/!b;n;c--forecolor: " + data.forecolor.value + ";'\'' " + cssfile + "_2.css");\
\
      config.set("bgdarkness", data.bgdarkness.value);\
      execSync("bin/sed -i '\''/GUI_ID: 101/!b;n;c--bgdarkness: " + data.bgdarkness.value + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 101/!b;n;c--bgdarkness: " + data.bgdarkness.value + ";'\'' " + cssfile + "_2.css");\
\
      config.set("ftopacity", data.ftopacity.value);\
      execSync("bin/sed -i '\''/GUI_ID: 102/!b;n;c--ftopacity: " + data.ftopacity.value + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 102/!b;n;c--ftopacity: " + data.ftopacity.value + ";'\'' " + cssfile + "_2.css");\
      config.set("fthide", data.fthide);\
      var borderInt = data.fthide ? "3840" : "0";\
      execSync("bin/sed -i '\''/GUI_ID: 200/!b;n;c@media (orientation: landscape) and (max-width: " + borderInt + "px) {'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 200/!b;n;c@media (orientation: landscape) and (max-width: " + borderInt + "px) {'\'' " + cssfile + "_2.css");\
      config.set("headerbackdrop", data.headerbackdrop);\
      var headerInt = data.headerbackdrop ? "none" : "unset";\
      execSync("bin/sed -i '\''/GUI_ID: 103/!b;n;c--headerbackdrop: " + headerInt + ";'\'' " + cssfile + "_2.css");\
\
      execSync("/bin/cp " + cssfile + "_" + config.get("ContempMod") + ".css " + cssfile + ".css");\
      self.commandRouter.reloadUi();\
      setTimeout(function () {\
        self.commandRouter.pushToastMessage("success", "Appearance", "Save global modification data to css file sccessfully");\
      }, 2000);\
    } catch (e) {\
      self.logger.error(e);\
      self.commandRouter.pushToastMessage("error", "Appearance", "Error on save global modification data to css file");\
    }\
};\
\
volumioAppearance.prototype.setAlbumartModUI = function (data) {\
  var self = this;\
\
    try {\
      data.aadim = self.minmax("Albumart resize", data.aadim, aart[0]);\
      config.set("aadim", data.aadim);\
      execSync("bin/sed -i '\''/GUI_ID: 110/!b;n;c--aadim: " + data.aadim + "px;'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 110/!b;n;c--aadim: " + data.aadim + "px;'\'' " + cssfile + "_2.css");\
      data.aaspace = self.minmax("Albumart resize", data.aaspace, aart[1]);\
      config.set("aaspace", data.aaspace);\
      execSync("bin/sed -i '\''/GUI_ID: 111/!b;n;c--aaspace: " + data.aaspace + "vh;'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 111/!b;n;c--aaspace: " + data.aaspace + "vh;'\'' " + cssfile + "_2.css");\
\
      config.set("border", data.border);\
      var borderInt = data.border ? "1" : "0";\
      execSync("bin/sed -i '\''/GUI_ID: 112/!b;n;c--border: " + borderInt + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 112/!b;n;c--border: " + borderInt + ";'\'' " + cssfile + "_2.css");\
      config.set("bordercolor", data.bordercolor.value);\
      config.set("bordercolor_title", data.bordercolor.label);\
      execSync("bin/sed -i '\''/GUI_ID: 114/!b;n;c--bordercolor: " + data.bordercolor.value + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 114/!b;n;c--bordercolor: " + data.bordercolor.value + ";'\'' " + cssfile + "_2.css");\
      config.set("bordercorner", data.bordercorner);\
      var bordercornerInt = data.bordercorner ? "1" : "0";\
      execSync("bin/sed -i '\''/GUI_ID: 113/!b;n;c--bordercorner: " + bordercornerInt + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 113/!b;n;c--bordercorner: " + bordercornerInt + ";'\'' " + cssfile + "_2.css");\
      config.set("aashadow", data.aashadow);\
      var aashadowInt = data.aashadow ? "1" : "0";\
      execSync("bin/sed -i '\''/GUI_ID: 115/!b;n;c--aashadow: " + aashadowInt + ";'\'' " + cssfile + "_1.css");\
      execSync("bin/sed -i '\''/GUI_ID: 115/!b;n;c--aashadow: " + aashadowInt + ";'\'' " + cssfile + "_2.css");\
\
      execSync("/bin/cp " + cssfile + "_" + config.get("ContempMod") + ".css " + cssfile + ".css");\
      self.commandRouter.reloadUi();\
      setTimeout(function () {\
        self.commandRouter.pushToastMessage("success", "Appearance", "Save albumart changes to css file sccessfully");\
      }, 2000);\
    } catch (e) {\
      self.commandRouter.pushToastMessage("error", "Appearance", "Error on save albumart changes to css file");\
      self.logger.error(e);\
    }\
};\
volumioAppearance.prototype.setTitle1ModUI = function (data) {\
  var self = this;\
\
    try {\
      data.buttons = self.minmax("Enlarge play buttonsbar", data.buttons, tinfo[0]);\
      config.set("buttons", data.buttons);\
      execSync("bin/sed -i '\''/GUI_ID: 119/!b;n;c--buttons: " + data.buttons + ";'\'' " + cssfile + "_1.css");\
      config.set("textwrap", data.textwrap);\
      var textwrapTxt = data.textwrap ? "normal" : "nowrap";\
      execSync("bin/sed -i '\''/GUI_ID: 120/!b;n;c--textwrap: " + textwrapTxt + ";'\'' " + cssfile + "_1.css");\
      data.tinfoY = self.minmax("Track info container top position", data.tinfoY, tinfo[2]);\
      config.set("tinfoY", data.tinfoY);\
      execSync("bin/sed -i '\''/GUI_ID: 121/!b;n;c--tinfoY: " + data.tinfoY + "vh;'\'' " + cssfile + "_1.css");\
      data.title = self.minmax("Fontsize of title", data.title, tinfo[3]);\
      config.set("title", data.title);\
      execSync("bin/sed -i '\''/GUI_ID: 122/!b;n;c--title600: " + data.title + "px;'\'' " + cssfile + "_1.css");\
      data.title2 = self.minmax("Fontsize of title", data.title2, tinfo[4]);\
      config.set("title2", data.title2);\
      execSync("bin/sed -i '\''/GUI_ID: 123/!b;n;c--title601: " + data.title2 + "px;'\'' " + cssfile + "_1.css");\
      data.artist = self.minmax("Fontsize of artist", data.artist, tinfo[5]);\
      config.set("artist", data.artist);\
      execSync("bin/sed -i '\''/GUI_ID: 124/!b;n;c--artist: " + data.artist + "px;'\'' " + cssfile + "_1.css");\
      data.srate = self.minmax("Fontsize of sample rate", data.srate, tinfo[6]);\
      config.set("srate", data.srate);\
      execSync("bin/sed -i '\''/GUI_ID: 125/!b;n;c--srate: " + data.srate + "px;'\'' " + cssfile + "_1.css");\
      data.sratespace = self.minmax("Space between title and sample rate", data.sratespace, tinfo[7]);\
      config.set("sratespace", data.sratespace);\
      execSync("bin/sed -i '\''/GUI_ID: 126/!b;n;c--sratespace: " + data.sratespace + "px;'\'' " + cssfile + "_1.css");\
\
      execSync("/bin/cp " + cssfile + "_" + config.get("ContempMod") + ".css " + cssfile + ".css");\
      self.commandRouter.reloadUi();\
      setTimeout(function () {\
        self.commandRouter.pushToastMessage("success", "Appearance", "Save trackinfo changes to css file sccessfully");\
      }, 2000);\
    } catch (e) {\
      self.commandRouter.pushToastMessage("error", "Appearance", "Error on save trackinfo changes to css file");\
      self.logger.error(e);\
    }\
};\
volumioAppearance.prototype.setTitle2ModUI = function (data) {\
  var self = this;\
\
    try {\
      data.buttons = self.minmax("Enlarge play buttonsbar", data.buttons, tinfo2[0]);\
      config.set("buttons", data.buttons);\
      execSync("bin/sed -i '\''/GUI_ID: 119/!b;n;c--buttons: " + data.buttons + ";'\'' " + cssfile + "_2.css");\
      config.set("textwrap", data.textwrap);\
      var textwrapTxt = data.textwrap ? "normal" : "nowrap";\
      execSync("bin/sed -i '\''/GUI_ID: 120/!b;n;c--textwrap: " + textwrapTxt + ";'\'' " + cssfile + "_2.css");\
      config.set("resolution", data.resolution.value);\
      config.set("resolution_title", data.resolution.label);\
\
      data.tinfoY = self.minmax("Track info container top position", data.tinfoY, tinfo2[3]);\
      config.set("tinfoY", data.tinfoY);\
      execSync("bin/sed -i '\''/GUI_ID: 121/!b;n;c--tinfoY: " + data.tinfoY + "vh;'\'' " + cssfile + "_2.css");\
      data.title = self.minmax("Fontsize of title", data.title, tinfo2[4]);\
      config.set("title", data.title);\
      execSync("bin/sed -i '\''/GUI_ID: 122/!b;n;c--title: " + data.title + "px;'\'' " + cssfile + "_2.css");\
      data.artist = self.minmax("Fontsize of artist", data.artist, tinfo2[5]);\
      config.set("artist", data.artist);\
      execSync("bin/sed -i '\''/GUI_ID: 123/!b;n;c--artist: " + data.artist + "px;'\'' " + cssfile + "_2.css");\
      data.srate = self.minmax("Fontsize of sample rate", data.srate, tinfo2[6]);\
      config.set("srate", data.srate);\
      execSync("bin/sed -i '\''/GUI_ID: 124/!b;n;c--srate: " + data.srate + "px;'\'' " + cssfile + "_2.css");\
      data.sratespace = self.minmax("Space between title and sample rate", data.sratespace, tinfo2[7]);\
      config.set("sratespace", data.sratespace);\
      execSync("bin/sed -i '\''/GUI_ID: 125/!b;n;c--sratespace: " + data.sratespace + "px;'\'' " + cssfile + "_2.css");\
\
      data.tinfoY2 = self.minmax("Track info container top position", data.tinfoY2, tinfo2[8]);\
      config.set("tinfoY2", data.tinfoY2);\
      execSync("bin/sed -i '\''/GUI_ID: 131/!b;n;c--tinfoY2: " + data.tinfoY2 + "vh;'\'' " + cssfile + "_2.css");\
      data.title2 = self.minmax("Fontsize of title", data.title2, tinfo2[9]);\
      config.set("title2", data.title2);\
      execSync("bin/sed -i '\''/GUI_ID: 132/!b;n;c--title2: " + data.title2 + "px;'\'' " + cssfile + "_2.css");\
      data.artist2 = self.minmax("Fontsize of artist", data.artist2, tinfo2[10]);\
      config.set("artist2", data.artist2);\
      execSync("bin/sed -i '\''/GUI_ID: 133/!b;n;c--artist2: " + data.artist2 + "px;'\'' " + cssfile + "_2.css");\
      data.srate2 = self.minmax("Fontsize of sample rate", data.srate2, tinfo2[11]);\
      config.set("srate2", data.srate2);\
      execSync("bin/sed -i '\''/GUI_ID: 134/!b;n;c--srate2: " + data.srate2 + "px;'\'' " + cssfile + "_2.css");\
      data.sratespace2 = self.minmax("Space between title and sample rate", data.sratespace2, tinfo2[12]);\
      config.set("sratespace2", data.sratespace2);\
      execSync("bin/sed -i '\''/GUI_ID: 135/!b;n;c--sratespace2: " + data.sratespace2 + "px;'\'' " + cssfile + "_2.css");\
\
      data.tinfoY3 = self.minmax("Track info container top position", data.tinfoY3, tinfo2[13]);\
      config.set("tinfoY3", data.tinfoY3);\
      execSync("bin/sed -i '\''/GUI_ID: 141/!b;n;c--tinfoY3: " + data.tinfoY3 + "vh;'\'' " + cssfile + "_2.css");\
      data.title3 = self.minmax("Fontsize of title", data.title3, tinfo2[14]);\
      config.set("title3", data.title3);\
      execSync("bin/sed -i '\''/GUI_ID: 142/!b;n;c--title3: " + data.title3 + "px;'\'' " + cssfile + "_2.css");\
      data.artist3 = self.minmax("Fontsize of artist", data.artist3, tinfo2[15]);\
      config.set("artist3", data.artist3);\
      execSync("bin/sed -i '\''/GUI_ID: 143/!b;n;c--artist3: " + data.artist3 + "px;'\'' " + cssfile + "_2.css");\
      data.srate3 = self.minmax("Fontsize of sample rate", data.srate3, tinfo2[16]);\
      config.set("srate3", data.srate3);\
      execSync("bin/sed -i '\''/GUI_ID: 144/!b;n;c--srate3: " + data.srate3 + "px;'\'' " + cssfile + "_2.css");\
      data.sratespace3 = self.minmax("Space between title and sample rate", data.sratespace3, tinfo2[17]);\
      config.set("sratespace3", data.sratespace3);\
      execSync("bin/sed -i '\''/GUI_ID: 145/!b;n;c--sratespace3: " + data.sratespace3 + "px;'\'' " + cssfile + "_2.css");\
\
      execSync("/bin/cp " + cssfile + "_" + config.get("ContempMod") + ".css " + cssfile + ".css");\
      self.commandRouter.reloadUi();\
      setTimeout(function () {\
        self.commandRouter.pushToastMessage("success", "Appearance", "Save trackinfo changes to css file sccessfully");\
      }, 2000);\
    } catch (e) {\
      self.commandRouter.pushToastMessage("error", "Appearance", "Error on save trackinfo changes to css file");\
      self.logger.error(e);\
    }\
};\
\
volumioAppearance.prototype.minmax = function (message, value, attrib) {\
  var self = this;\
  if (Number.isNaN(parseInt(value, 10)) || !isFinite(value)) {\
      return attrib[2];\
  }\
    if (value < attrib[0]) {\
      self.commandRouter.pushToastMessage("info", "Appearance", "The value for " + message + " has been adjusted to the lowest possible (" + attrib[0] + ") because the value entered is too small.");\
      return min;\
    }\
    if (value > attrib[1]) {\
      self.commandRouter.pushToastMessage("info", "Appearance", "The value for " + message + " has been adjusted to the highest possible (" + attrib[1] + ")  because the value entered is too big.");\
      return max;\
    }\
    return parseInt(value, 10);\
};
' $AP

# remove data to generate new config data
DATACONF=/data/configuration/miscellanea/appearance/config.json
[ -f "$DATACONF" ] && rm $DATACONF

# patch MPD index.js switch albumartist at first in genre view (optional)
mpd=/volumio/app/plugins/music_service/mpd/index.js
[ ! -d "backup/mpd" ] && mkdir backup/mpd
if ! grep -q '//albumart: self.getAlbumArt' $mpd; then cp $mpd backup/mpd; fi

sed -i '0,/genreName + '\'' '\'' + self.commandRouter.getI18nString('\''COMMON.ARTISTS'\'')/ s//genreName + '\'' '\'' + self.commandRouter.getI18nString('\''COMMON.ALBUMS'\'')/' $mpd
sed -i '0,/genreName + '\'' '\'' + self.commandRouter.getI18nString('\''COMMON.ALBUMS'\'')/ s//genreName + '\'' '\'' + self.commandRouter.getI18nString('\''COMMON.ARTISTS'\'')/' $mpd

sed -i '/if (album !== '\'''\'')/,/service: '\''mpd'\''/{s/response.navigation.lists\[0\]/response.navigation.lists\[1\]/g;}' $mpd
sed -i '/if (albumartist !== '\'''\'')/,/service: '\''mpd'\''/{s/response.navigation.lists\[1\]/response.navigation.lists\[0\]/g;}' $mpd
sed -i '/if (artist !== '\'''\'')/,/service: '\''mpd'\''/{s/response.navigation.lists\[1\]/response.navigation.lists\[0\]/g;}' $mpd

if ! grep -q '//albumart: self.getAlbumArt({artist: albumartist}, undefined, '\''users'\''),' $mpd; then
	sed -i 's/albumart: self.getAlbumArt({artist: albumartist}, undefined, '\''users'\''),/\/\/albumart: self.getAlbumArt({artist: albumartist}, undefined, '\''users'\''),/g' $mpd
	sed -i '/\/\/albumart: self.getAlbumArt({artist: albumartist}, undefined, '\''users'\''),/a\                      albumart: albumart,' $mpd
fi

# restart
volumio vrestart
