#!/bin/bash

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (divypattani): " username
    username=${username:-divypattani}
    read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login $username password $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/268/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0925t070652_o72086_2025m0925t105826.h5"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/268/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0925t070652_o72086_2025m0925t105826.h5 -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/268/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0925t070652_o72086_2025m0925t105826.h5 | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

fetch_urls() {
  if command -v curl >/dev/null 2>&1; then
      setup_auth_curl
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  elif command -v wget >/dev/null 2>&1; then
      # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
      echo
      echo "WARNING: Can't find curl, use wget instead."
      echo "WARNING: Script may not correctly identify Earthdata Login integrations."
      echo
      setup_auth_wget
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --output-document $stripped_query_params --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  else
      exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
  fi
}

fetch_urls <<'EDSCEOF'
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/268/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0925t070652_o72086_2025m0925t105826.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/267/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0924t072602_o72072_2025m0925t171315.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/266/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0923t074506_o72058_2025m0923t094931.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/266/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0923t074506_o72058_2025m0923t094807.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/265/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0922t080413_o72044_2025m0922t101517.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/264/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0921t082319_o72030_2025m0921t121303.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/264/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0921t064150_o72029_2025m0921t103109.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/263/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0920t070057_o72015_2025m0920t104647.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/262/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0919t072005_o72001_2025m0919t131128.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/261/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0918t073912_o71987_2025m0918t141335.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/260/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0917t075818_o71973_2025m0917t100622.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/259/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0916t081725_o71959_2025m0916t101649.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/259/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0916t063555_o71958_2025m0916t101632.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/258/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0915t065502_o71944_2025m0915t103237.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/257/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0914t071408_o71930_2025m0914t105133.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/256/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0913t073314_o71916_2025m0913t111102.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/255/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0912t075221_o71902_2025m0912t094513.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/254/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0911t081127_o71888_2025m0911t100144.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/254/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0911t062957_o71887_2025m0911t100140.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/253/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0910t064903_o71873_2025m0910t173838.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/252/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0909t070900_o71859_2025m0909t104351.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/251/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0908t072716_o71845_2025m0908t111518.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/250/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0907t074622_o71831_2025m0907t093826.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/249/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0906t080528_o71817_2025m0906t101430.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/248/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0905t082432_o71803_2025m0905t115527.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/248/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0905t064302_o71802_2025m0905t101937.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/247/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0904t070208_o71788_2025m0904t103702.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/246/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0903t072114_o71774_2025m0903t120418.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/245/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0902t074020_o71760_2025m0902t092802.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/244/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0901t075926_o71746_2025m0901t100204.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/243/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0831t081832_o71732_2025m0831t115804.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/243/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0831t063702_o71731_2025m0831t102117.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/242/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0830t065608_o71717_2025m0830t103313.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/241/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0829t071513_o71703_2025m0829t105011.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/240/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0828t073419_o71689_2025m0828t110651.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/239/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0827t075324_o71675_2025m0827t131000.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/238/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0826t081229_o71661_2025m0826t101124.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/238/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0826t063100_o71660_2025m0826t101216.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/237/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0825t065001_o71646_2025m0904t184239.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/236/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0824t070907_o71632_2025m0824t104844.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/235/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0823t072813_o71618_2025m0823t110228.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/234/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0822t074719_o71604_2025m0822t100409.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/233/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0821t080624_o71590_2025m0821t100302.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/232/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0820t082531_o71576_2025m0820t115323.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/232/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0820t064401_o71575_2025m0820t103114.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/231/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0819t070309_o71561_2025m0819t103437.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/230/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0818t072216_o71547_2025m0818t105030.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/229/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0817t074124_o71533_2025m0817t111511.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/228/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0816t080031_o71519_2025m0816t100604.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/227/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0815t081939_o71505_2025m0815t115406.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/227/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0815t063809_o71504_2025m0815t101710.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/226/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0814t065716_o71490_2025m0814t104520.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/225/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0813t071624_o71476_2025m0813t110006.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/224/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0812t073531_o71462_2025m0812t110932.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/222/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0810t081435_o71434_2025m0810t100258.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/222/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0810t063215_o71433_2025m0810t100249.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/221/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0809t065122_o71419_2025m0809t101710.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/220/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0808t071030_o71405_2025m0808t104213.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/219/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0807t072937_o71391_2025m0807t105923.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/218/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0806t074843_o71377_2025m0806t095619.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/217/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0805t080750_o71363_2025m0805t100146.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/216/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0804t082656_o71349_2025m0804t115945.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/216/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0804t064526_o71348_2025m0804t102230.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/215/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0803t070433_o71334_2025m0803t104657.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/215/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0803t070433_o71334_2025m0803t104237.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/214/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0802t072339_o71320_2025m0802t105218.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/213/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0801t074245_o71306_2025m0801t111651.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/212/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0731t080151_o71292_2025m0731t100523.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/211/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0730t082057_o71278_2025m0730t120707.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/211/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0730t063927_o71277_2025m0730t120132.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/210/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0729t065833_o71263_2025m0729t103417.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/209/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0728t071739_o71249_2025m0728t105718.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/208/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0727t073644_o71235_2025m0727t111517.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/207/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0726t075550_o71221_2025m0726t170627.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/206/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0725t081456_o71207_2025m0725t100915.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/206/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0725t063327_o71206_2025m0725t101029.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/205/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0724t065232_o71192_2025m0724t101903.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/204/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0723t071137_o71178_2025m0723t113356.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/203/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0722t073042_o71164_2025m0722t110941.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/203/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0722t073042_o71164_2025m0722t111230.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/202/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0721t074947_o71150_2025m0721t095054.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/201/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0720t080852_o71136_2025m0720t102718.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/200/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0719t082757_o71122_2025m0719t115402.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/200/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0719t064627_o71121_2025m0719t102135.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/199/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0718t070532_o71107_2025m0718t103829.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/198/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0717t072437_o71093_2025m0717t110451.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/197/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0716t074341_o71079_2025m0716t120822.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/196/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0715t080246_o71065_2025m0721t104554.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/195/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0714t082150_o71051_2025m0714t114550.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/195/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0714t064020_o71050_2025m0714t101847.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/194/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0713t065925_o71036_2025m0713t102814.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/193/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0712t071829_o71022_2025m0712t105711.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/192/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0711t073733_o71008_2025m0711t141150.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/191/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0710t075637_o70994_2025m0710t095237.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/190/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0709t081541_o70980_2025m0709t115816.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/190/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0709t063411_o70979_2025m0709t115822.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/189/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0708t065315_o70965_2025m0708t103235.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/188/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0707t071219_o70951_2025m0707t105055.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/188/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0707t071219_o70951_2025m0707t105214.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/187/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0706t073122_o70937_2025m0707t004934.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/186/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0705t075025_o70923_2025m0820t190810.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/185/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0704t080929_o70909_2025m0704t100848.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/184/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0703t082832_o70895_2025m0703t120744.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/184/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0703t064702_o70894_2025m0703t103033.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/183/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0702t070605_o70880_2025m0702t104943.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/182/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0701t072508_o70866_2025m0701t105827.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/181/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0630t074411_o70852_2025m0630t095117.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/180/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0629t080314_o70838_2025m0629t095631.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/179/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0628t082216_o70824_2025m0628t115734.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/179/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0628t064046_o70823_2025m0628t101617.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/178/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0627t065951_o70809_2025m0627t103818.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/177/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0626t071853_o70795_2025m0626t105131.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/176/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0625t073755_o70781_2025m0625t104754.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/175/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0624t075657_o70767_2025m0624t100253.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/174/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0623t081559_o70753_2025m0623t102229.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/174/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0623t063429_o70752_2025m0623t102102.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/173/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0622t065331_o70738_2025m0622t104121.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/172/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0621t071232_o70724_2025m0621t104301.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/171/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0620t073134_o70710_2025m0620t111340.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/170/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0619t075035_o70696_2025m0619t094308.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/169/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0618t080937_o70682_2025m0618t101303.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/168/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0617t082838_o70668_2025m0617t120700.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/167/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0616t070609_o70653_2025m0616t104714.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/166/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0615t072510_o70639_2025m0615t111051.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/165/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0614t074411_o70625_2025m0614t112043.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/164/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0613t080312_o70611_2025m0613t100241.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/163/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0612t082212_o70597_2025m0612t120350.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/163/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0612t064028_o70596_2025m0612t110907.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/162/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0611t065943_o70582_2025m0611t104227.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/161/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0610t071843_o70568_2025m0610t105714.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/160/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0609t073743_o70554_2025m0609t100411.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/159/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0608t075643_o70540_2025m0608t095454.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/158/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0607t081543_o70526_2025m0607t102350.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/158/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0607t063413_o70525_2025m0607t102728.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/157/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0606t065313_o70511_2025m0606t103850.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/156/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0605t071212_o70497_2025m0605t105511.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/155/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0604t073112_o70483_2025m0604t140801.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/154/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0603t075011_o70469_2025m0603t094346.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/153/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0602t080910_o70455_2025m0602t100425.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/152/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0601t082809_o70441_2025m0601t115420.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/152/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0601t064639_o70440_2025m0601t102131.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/151/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0531t070538_o70426_2025m0531t102950.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/150/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0530t072437_o70412_2025m0530t111620.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/149/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0529t074336_o70398_2025m0529t095255.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/148/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0528t080235_o70384_2025m0528t100631.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/147/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0527t082133_o70370_2025m0527t120114.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/147/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0527t064003_o70369_2025m0527t101813.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/146/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0526t065901_o70355_2025m0526t103755.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/145/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0525t071759_o70341_2025m0525t110452.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/144/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0524t073658_o70327_2025m0524t111036.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/143/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0523t075556_o70313_2025m0523t095445.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/142/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0522t081453_o70299_2025m0522t104757.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/142/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0522t063323_o70298_2025m0522t111301.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/141/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0521t065221_o70284_2025m0521t104544.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/140/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0520t071118_o70270_2025m0520t113426.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/139/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0519t073016_o70256_2025m0519t111156.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/138/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0518t074913_o70242_2025m0518t094631.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/137/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0517t080811_o70228_2025m0517t101146.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/136/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0516t082706_o70214_2025m0516t121706.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/136/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0516t064536_o70213_2025m0516t102319.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/135/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0515t070433_o70199_2025m0515t110958.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/134/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0514t072317_o70185_2025m0514t111257.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/133/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0513t074227_o70171_2025m0513t111606.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/133/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0513t074227_o70171_2025m0513t111433.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/132/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0512t080124_o70157_2025m0512t095838.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/131/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0511t082020_o70143_2025m0511t120818.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/131/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0511t063850_o70142_2025m0511t103019.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/130/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0510t065746_o70128_2025m0510t103915.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/129/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0509t071643_o70114_2025m0509t110502.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/128/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0508t073539_o70100_2025m0508t092648.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/127/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0507t075435_o70086_2025m0507t095110.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/126/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0506t081331_o70072_2025m0506t101141.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/126/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0506t063201_o70071_2025m0506t101146.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/125/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0505t065056_o70057_2025m0505t105050.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/124/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0504t070952_o70043_2025m0504t110745.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/123/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0503t072848_o70029_2025m0503t110630.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/122/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0502t074745_o70015_2025m0502t095737.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/121/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0501t080641_o70001_2025m0501t101238.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/120/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0430t082536_o69987_2025m0430t122015.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/120/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0430t082536_o69987_2025m0430t122110.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/120/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0430t064405_o69986_2025m0430t104200.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/119/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0429t070300_o69972_2025m0430t095756.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/118/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0428t072155_o69958_2025m0428t110656.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/117/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0427t074050_o69944_2025m0427t095550.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/116/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0426t075944_o69930_2025m0426t100142.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/116/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0426t075944_o69930_2025m0426t100040.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/115/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0425t081839_o69916_2025m0425t120409.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/115/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0425t063709_o69915_2025m0425t102741.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/114/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0424t065603_o69901_2025m0424t104708.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/113/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0423t071457_o69887_2025m0423t133420.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/112/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0422t073352_o69873_2025m0422t094350.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/111/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0421t075246_o69859_2025m0421t095633.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/111/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0421t075246_o69859_2025m0421t095753.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/110/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0420t081140_o69845_2025m0420t102204.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/110/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0420t063009_o69844_2025m0420t102203.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/109/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0419t064903_o69830_2025m0419t102748.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/108/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0418t070757_o69816_2025m0418t111047.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/107/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0417t072651_o69802_2025m0417t111108.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/106/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0416t074545_o69788_2025m0416t100302.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/105/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0415t080438_o69774_2025m0415t101206.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/104/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0414t082332_o69760_2025m0414t115937.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/104/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0414t064201_o69759_2025m0414t102618.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/103/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0413t070055_o69745_2025m0413t104358.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/102/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0412t071949_o69731_2025m0412t110645.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/101/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0411t073842_o69717_2025m0411t095354.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/100/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0410t075735_o69703_2025m0410t101255.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/099/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0409t081628_o69689_2025m0409t102712.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/099/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0409t063458_o69688_2025m0409t102153.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/098/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0408t065351_o69674_2025m0408t212453.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/097/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0407t071244_o69660_2025m0407t110157.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/096/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0406t073137_o69646_2025m0406t103931.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/095/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0405t075030_o69632_2025m0405t101808.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/094/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0404t080924_o69618_2025m0404t101850.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/094/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0404t062753_o69617_2025m0404t101902.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/093/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0403t064646_o69603_2025m0403t105040.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/092/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0402t070539_o69589_2025m0402t111032.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/091/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0401t072432_o69575_2025m0401t110642.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/090/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0331t074324_o69561_2025m0331t094702.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/089/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0330t080217_o69547_2025m0330t101008.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/088/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0329t082109_o69533_2025m0329t120359.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/088/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0329t063938_o69532_2025m0329t102615.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/088/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0329t063938_o69532_2025m0329t102800.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/087/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0328t065831_o69518_2025m0328t105443.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/086/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0327t071723_o69504_2025m0327t110030.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/085/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0326t073617_o69490_2025m0326t095649.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/083/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0324t081410_o69462_2025m0324t101556.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/083/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0324t063240_o69461_2025m0324t101609.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/082/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0323t065137_o69447_2025m0323t104259.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/081/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0322t071033_o69433_2025m0322t110154.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/080/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0321t072934_o69419_2025m0321t093455.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/079/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0320t074827_o69405_2025m0320t100200.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/079/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0320t074827_o69405_2025m0320t100037.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/078/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0319t080722_o69391_2025m0319t101652.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/078/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0319t062551_o69390_2025m0319t101000.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/077/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0318t064448_o69376_2025m0318t113153.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/077/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0318t064448_o69376_2025m0318t113035.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/076/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0317t070344_o69362_2025m0317t105236.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/075/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0316t072240_o69348_2025m0316t110848.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/074/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0315t074136_o69334_2025m0315t093822.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/073/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0314t080033_o69320_2025m0314t101421.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/072/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0313t081929_o69306_2025m0313t120744.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/072/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0313t063758_o69305_2025m0313t101444.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/071/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0312t065655_o69291_2025m0312t103720.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/071/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0312t065655_o69291_2025m0312t103605.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/070/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0311t071551_o69277_2025m0311t110856.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/069/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0310t073447_o69263_2025m0310t113030.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/068/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0309t075343_o69249_2025m0309t100407.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/067/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0308t081239_o69235_2025m0308t091628.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/067/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0308t063109_o69234_2025m0308t091435.h5
https://data.gesdisc.earthdata.nasa.gov/data/SO2/OMPS_NPP_NMSO2_PCA_L2.2/2025/066/OMPS-NPP_NMSO2-PCA-L2_v2.0_2025m0307t065006_o69220_2025m0307t094325.h5
EDSCEOF