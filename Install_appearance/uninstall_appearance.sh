#!/bin/bash
cd /home/volumio/Install_appearance

# restore css file
www3=/volumio/http/www3/styles
pushd backup/http
ID=$(ls app-??????????.css)
ID=${ID#*app-}
ID=${ID%.*}
[ -f "app-${ID}.css" ] && cp -f app-${ID}.css $www3
[ -f "${www3}/app-${ID}_0.css" ] && rm ${www3}/app-${ID}_0.css
[ -f "${www3}/app-${ID}_1.css" ] && rm ${www3}/app-${ID}_1.css
[ -f "${www3}/app-${ID}_2.css" ] && rm ${www3}/app-${ID}_2.css
popd

# restore appearance files
conf=/volumio/app/plugins/miscellanea/appearance
pushd backup/appearance
[ -f "config.json" ] && cp -f config.json $conf
[ -f "index.js" ] && cp -f index.js $conf
[ -f "UIConfig.json" ] && cp -f UIConfig.json $conf
popd

# restore mpd
mpd=/volumio/app/plugins/music_service/mpd
pushd backup/mpd
[ -f "index.js" ] && cp -f index.js $mpd
popd

# remove data to generate new config data
DATACONF=/data/configuration/miscellanea/appearance/config.json
[ -f "$DATACONF" ] && rm $DATACONF

# restart
volumio vrestart