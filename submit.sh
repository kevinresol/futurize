#!/bin/sh

zip -r temp.zip src haxelib.json README.md LICENSE
haxelib submit temp.zip
rm temp.zip