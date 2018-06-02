// Common client-side webpack configuration used by webpack.hot.config and webpack.rails.config.
/* eslint-env node */

const webpack = require('webpack')
const { resolve } = require('path')
const ManifestPlugin = require('webpack-manifest-plugin')
const webpackConfigLoader = require('react-on-rails/webpackConfigLoader')

const configPath = resolve('..', 'config')
const { manifest } = webpackConfigLoader(configPath)
const devBuild = process.env.NODE_ENV !== 'production'

module.exports = {
  // context: __dirname,
  context: resolve(__dirname),
  entry: {
    // This will contain the app entry points defined by
    // webpack.client.rails.hot.config and webpack.client.rails.build.config
    // See use of 'vendor' in the CommonsChunkPlugin inclusion below.
    'vendor-bundle': [
      'es5-shim/es5-shim',
      'es5-shim/es5-sham',
      './app/babel-polyfill',
    ],
    // This will contain the app entry points defined by webpack.hot.config and webpack.rails.config
    'app-bundle': [
      './app/client_registration',
    ],
  },
  resolve: {
    modules: ['node_modules', 'app'],
    extensions: ['.js', '.jsx'],
  },
  plugins: [
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'development',
      DEBUG: false,
      TRACE_TURBOLINKS: devBuild,
      REPORT_TO_EXTERNAL_SERVICES: !devBuild,
    }),
    // https://webpack.github.io/docs/list-of-plugins.html#2-explicit-vendor-chunk
    new webpack.optimize.CommonsChunkPlugin({
      // This name 'vendor-bundle' ties into the entry definition
      name: 'vendor-bundle',
      // We don't want the default vendor.js name
      filename: 'vendor-bundle-[hash].js',
      // Passing Infinity just creates the commons chunk, but moves no modules into it.
      // In other words, we only put what's in the vendor entry definition in vendor-bundle.js
      minChunks(module) {
        // this assumes your vendor imports exist in the node_modules directory
        return module.context && module.context.indexOf('node_modules') !== -1
      },
    }),
    new ManifestPlugin({
      fileName: manifest,
      writeToFileEmit: true,
    }),
  ],
  module: {
    rules: [
      { test: /\.(ttf|eot)$/, use: 'file-loader' },
      {
        test: /\.(woff2?|jpe?g|png|gif|svg|ico)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              name: '[name]-[hash].[ext]',
              limit: 10000,
            },
          },
        ],
      },
    ],
  },
}
