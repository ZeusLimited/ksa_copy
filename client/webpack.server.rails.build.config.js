// Common webpack configuration for server bundle
/* eslint-env node */

const webpack = require('webpack')
const { resolve } = require('path')
const webpackConfigLoader = require('react-on-rails/webpackConfigLoader')

const configPath = resolve('..', 'config')
const { webpackOutputPath, webpackPublicOutputDir } = webpackConfigLoader(configPath)
const devBuild = process.env.NODE_ENV !== 'production'

module.exports = {
  // context: __dirname,
  entry: [
    'babel-polyfill',
    './app/server_registration',
  ],
  output: {
    filename: 'server-bundle.js',
    // Leading and trailing slashes ARE necessary.
    publicPath: `/${webpackPublicOutputDir}/`,
    path: webpackOutputPath,
  },
  resolve: {
    modules: ['node_modules', 'app'],
    extensions: ['.js', '.jsx'],
  },
  plugins: [
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'development',
      DEBUG: false,
      REPORT_TO_EXTERNAL_SERVICES: !devBuild,
    }),
    new webpack.IgnorePlugin(/react-image-lightbox/),
  ],
  module: {
    rules: [
      { test: /\.jsx?$/, use: 'babel-loader', exclude: /node_modules/ },
      {
        test: /\.s[ca]ss$/,
        use: [
          {
            loader: 'css-loader/locals',
            options: {
              modules: true,
              importLoaders: 2,
              localIdentName: '[name]__[local]__[hash:base64:5]',
              camelCase: true,
            },
          },
          {
            loader: 'sass-loader',
            options: {
              indentedSyntax: true,
            },
          },
          {
            loader: 'sass-resources-loader',
            options: {
              resources: './app/assets/styles/app-variables.sass',
            },
          },
        ],
      },
    ],
  },
}
