/* eslint no-var: 0, no-console: 0 */

import webpack from 'webpack'
import WebpackDevServer from 'webpack-dev-server'
import { resolve } from 'path'
import webpackConfigLoader from 'react-on-rails/webpackConfigLoader'

import webpackConfig from './webpack.client.rails.hot.config'

const compiler = webpack(webpackConfig)
const configPath = resolve('..', 'config')
const { hotReloadingUrl, hotReloadingPort, hotReloadingHostname } = webpackConfigLoader(configPath)

const devServer = new WebpackDevServer(compiler, {
  proxy: {
    '*': hotReloadingUrl,
  },
  hot: true,
  inline: true,
  historyApiFallback: true,
  quiet: false,
  noInfo: false,
  lazy: false,
  stats: {
    colors: true,
    hash: false,
    version: false,
    chunks: false,
    children: false,
  },
  headers: {
    'Access-Control-Allow-Origin': '*',
  },
})

devServer.listen(hotReloadingPort, hotReloadingHostname, (err) => {
  if (err) console.error(err)
  console.log(
    `=> 🔥  Webpack development server is running on ${hotReloadingUrl}`
  )
})
