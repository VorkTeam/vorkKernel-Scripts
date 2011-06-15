#!/bin/bash

cd $SCRIPT_DIR/CMScripts/$1.zip

echo Making update.zip ...
zip -r -y -q update *
echo
echo update.zip created

mv update.zip $signed_file


cd $VORKSCRIPT_DIR/