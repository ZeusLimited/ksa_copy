// Run with Rails server like this:
// rails s
// cd client && babel-node server-rails-hot.js
// Note that Foreman (Procfile.dev) has also been configured to take care of this.
/* eslint-env node */

const webpack = require('webpack')
const merge = require('webpack-merge')
const { resolve } = require('path')
const autoprefixer = require('autoprefixer')
const webpackConfigLoader = require('react-on-rails/webpackConfigLoader')
const DashboardPlugin = require('webpack-dashboard/plugin')
// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin

const configPath = resolve('..', 'config')
const { hotReloadingUrl, webpackOutputPath } = webpackConfigLoader(configPath)
const config = require('./webpack.client.base.config')

module.exports = merge.strategy(
  { entry: 'prepend' }
)(config, {
  devtool: 'eval-source-map',
  entry: {
    'app-bundle': [
      `webpack-dev-server/client?${hotReloadingUrl}`,
      'webpack/hot/only-dev-server',
    ],
    'vendor-bundle': [
      'whatwg-fetch',
      './app/turbolinks',
    ],
  },
  output: {
    filename: '[name]-[hash].js',
    path: webpackOutputPath,
    publicPath: `${hotReloadingUrl}/`,
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        query: {
          plugins: [
            [
              'react-transform',
              {
                superClasses: ['React.Component', 'BaseComponent', 'Component'],
                transforms: [
                  {
                    transform: 'react-transform-hmr',
                    imports: ['react'],
                    locals: ['module'],
                  },
                ],
              },
            ],
          ],
        },
      },
      {
        test: /\.s[ca]ss$/,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options: {
              modules: true,
              importLoaders: 3,
              localIdentName: '[name]__[local]__[hash:base64:5]',
              camelCase: true,
            },
          },
          {
            loader: 'postcss-loader',
            options: {
              plugins: () => [autoprefixer()],
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
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NamedModulesPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
    new DashboardPlugin(),
    // new BundleAnalyzerPlugin(),
  ],
})

console.log('Webpack HOT dev build for Rails') // eslint-disable-line no-console
