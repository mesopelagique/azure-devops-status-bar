#!/usr/bin/env bash

TMP="${TMPDIR}"
if [ "x$TMP" = "x" ]; then
  TMP="/tmp/"
fi
TMP="${TMP}kaluza.$$"
rm -rf "$TMP" || true
mkdir "$TMP"
if [ $? -ne 0 ]; then
  echo "failed to mkdir $TMP" >&2
  exit 1
fi

cd $TMP
archiveName=azure-devops-status-bar.app.zip
archive=$TMP/$archiveName
curl -sL https://github.com/mesopelagique/azure-devops-status-bar/releases/latest/download/$archiveName -o $archive

unzip -q $archive -d $TMP/

binary=$TMP/azure-devops-status-bar.app

dst="/Applications"
echo "Install into $dst/"
rm -rf $dst/azure-devops-status-bar.app
cp -r $binary $dst/

rm -rf "$TMP"
