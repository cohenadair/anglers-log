#!/bin/bash

# Copies “img.png" 5 times to the current directory. 
# It then scales each copy as many times as specified.

cp img.png mdpi.png
cp img.png hdpi.png
cp img.png xhdpi.png
cp img.png xxhdpi.png
cp img.png xxxhdpi.png

# Android Action Bar Icons
sips -Z 24 mdpi.png
sips -Z 36 hdpi.png
sips -Z 48 xhdpi.png
sips -Z 72 xxhdpi.png
sips -Z 96 xxxhdpi.png
