#!/usr/bin/env bash
# clean the dist directory
if [ -d dist ]; then
  rm -rf dist
fi

if [ ! -d dist ]; then
  mkdir dist
fi

# js compile and transform
node_modules/.bin/riot js  dist && node_modules/.bin/webpack --config=webpack.config.js

#delete the components directory
rm -rf dist/components

# timestamp = date +"%Y%m%d_%H%M%S"
# append # to end of js file for cache busting

date; echo;
