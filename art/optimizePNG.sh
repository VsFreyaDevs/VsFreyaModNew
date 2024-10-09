#!/bin/bash

# Find all files in PNG format and execute oxipng to optimize file sizes
cd ../assets/ && oxipng -o max --strip safe --fast --alpha {} **/*.png
