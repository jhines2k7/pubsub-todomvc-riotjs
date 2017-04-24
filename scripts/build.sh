#!/usr/bin/env bash
# clean the dist directory
if [ -d "dist" ]; then
  rm -rf dist
fi

if [ ! -d "dist" ]; then
  mkdir dist
fi

# js transform
node_modules/.bin/webpack --config=webpack.config.js

# copy index.html to dist directory
cp index.html dist

# copy css files to build directory
cp node_modules/todomvc-app-css/index.css build
cp node_modules/todomvc-common/base.css build

# change the src property of the script tag to app.js
sed -i 's/dist\/bundle.js/bundle.js/g' dist/index.html
sed -i 's/node_modules\/todomvc-common\/base.css/base.css/g' dist/index.html
sed -i 's/node_modules\/todomvc-app-css\/index.css/index.css/g' dist/index.html

docker build -t jhines2017/pubsub-todomvc-riotjs .

date; echo;
