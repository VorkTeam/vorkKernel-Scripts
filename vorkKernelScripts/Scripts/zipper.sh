#!/bin/bash

cd $VORKSCRIPT_DIR/$1.zip

echo Making update.zip ...
zip -r -y -q update *
echo
echo update.zip created

mv update.zip ../$signed_file


cd $VORKSCRIPT_DIR/
