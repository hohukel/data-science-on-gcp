#!/bin/bash

export HOSTNAME=ch6cluster-m
export PORT=1080
rm -rf /tmp/junk
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --proxy-server="socks5://localhost:${PORT}" \
    --user-data-dir=/tmp/junk



#/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  #--proxy-server="sock5://localhost:1080" \
  #--host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" \
  #--user-data-dir=/tmp/junk
