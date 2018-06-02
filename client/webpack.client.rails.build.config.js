// Run like this:
// cd client && npm run build:client
// Note that Foreman (Procfile.dev) has also been configured to take care of this.
/* eslint-env node */


const ExtractTextPlugin = require('extract-text-webpack-plugin')
const merge = require('webpack-merge')
const { resolve } = require('path')
const autoprefixer = require('autoprefixer')
const webpackConfigLoader = require('react-on-rails/webpackConfigLoader')

const configPath = resolve('..', 'config')
const { webpackOutputPath, webpackPublicOutputDir } = webpackConfigLoader(configPath)
const config = require('./webpack.client.base.config')

const devBuild = process.env.NODE_ENV !== 'production'

if (devBuild) {
  console.log('Webpack dev build for Rails') // eslint-disable-line no-console
  config.devtool = 'eval-source-map'
} else {
  console.log('Webpack production build for Rails') // eslint-disable-line no-console
}

module.exports = merge(config, {
  entry: {
    'vendor-bundle': [
      'whatwg-fetch',
      './app/turbolinks',
    ],
  },
  output: {
    filename: '[name]-[hash].js',
    // Leading and trailing slashes ARE necessary.
    publicPath: `/${webpackPublicOutputDir}/`,
    path: webpackOutputPath,
  },
  // See webpack.common.config for adding modules common to both the webpack dev server and rails
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        use: 'babel-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.s[ca]ss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            {
              loader: 'css-loader',
              options: {
                minimize: true,
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
        }),
      },
      {
        test: require.resolve('react'),
        use: {
          loader: 'imports-loader',
          options: {
            shim: 'es5-shim/es5-shim',
            sham: 'es5-shim/es5-sham',
          },
        },
      },
    ],
  },
  plugins: [
    new ExtractTextPlugin({
      filename: '[name]-[hash].css',
      allChunks: true,
    }),
  ],
})