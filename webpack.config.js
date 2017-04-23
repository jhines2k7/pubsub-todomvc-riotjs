/*eslint-env node */
"use strict";

var webpack = require("webpack");
var path = require("path");
var glob = require("glob");

module.exports = {
	entry: glob.sync("./js/*.js"),
	output: {
		path: __dirname + "/dist",
		filename: "bundle.js"
	},
	resolve: {
		root: path.resolve("./node_modules")
	},
	module: {
		loaders: [{
			loader: "babel-loader",
			query: {
				presets: ["es2015"],
				cacheDirectory: true
			}
		}]
	},
	plugins: [
		new webpack.ProvidePlugin({
			riot: "riot/riot"
		})
	],
    stats: {
        colors: true
    },
    devtool: 'source-map'
};
