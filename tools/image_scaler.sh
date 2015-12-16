#!/bin/bash

# Copies “img.png" 5 times to the current directory. 
# It then scales each copy as many times as specified.

cp img.png mdpi.png
cp img.png hdpi.png
cp img.png xhdpi.png
cp img.png xxhdpi.png
cp img.png xxxhdpi.png

# Other Images
# mdpi 1.0, hdpi 1.5, xhdpi 2.0, xxhdpi 3.0, xxxhdpi 4.0
sips -Z 72 mdpi.png
sips -Z 108 hdpi.png
sips -Z 144 xhdpi.png
sips -Z 216 xxhdpi.png
sips -Z 288 xxxhdpi.png
