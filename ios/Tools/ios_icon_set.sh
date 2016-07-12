#!/bin/bash

# ios_icon_set.sh

# Copies "icon.png" 8 times to the current directory. 
# It then scales each copy to the size for iOS icons.

cp icon.png 180.png
cp icon.png 152.png
cp icon.png 120.png
cp icon.png 80.png
cp icon.png 76.png
cp icon.png 58.png
cp icon.png 40.png
cp icon.png 29.png

sips -Z 180 180.png
sips -Z 152 152.png
sips -Z 120 120.png
sips -Z 80 80.png
sips -Z 76 76.png
sips -Z 58 58.png
sips -Z 40 40.png
sips -Z 29 29.png

