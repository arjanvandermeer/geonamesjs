#!/bin/bash

WORKPATH="/tmp/geonames.work"

cd /
if [ -d "$WORKPATH" ]; then
   rm -Rf $WORKPATH
fi