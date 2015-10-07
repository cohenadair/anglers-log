#!/bin/bash

# ios_icon_set.sh

# Copies "icon.png" 8 times to the current directory. 
# It then scales each copy to the size for iOS icons.

cp img.png mdpi.png
cp img.png hdpi.png
cp img.png xhdpi.png
cp img.png xxhdpi.png
cp img.png xxxhdpi.png

sips -Z 90 mdpi.png
sips -Z 135 hdpi.png
sips -Z 180 xhdpi.png
sips -Z 225 xxhdpi.png
sips -Z 265 xxxhdpi.png

