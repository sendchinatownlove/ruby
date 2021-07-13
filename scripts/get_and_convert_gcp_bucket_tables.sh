#!/bin/bash

mkdir copy && gsutil cp -r gs://sendchinatownlove-assets/public/assets

cd copy

# need to run brew install imagemagick before running mogrify
mogrify -format jpg $(find . -type f -name '*.png' | grep gallery) && rm $(find . -type f -name '*.png' | grep gallery)

gsutil -m cp -r . gs://sendchinatownlove-assets/public

