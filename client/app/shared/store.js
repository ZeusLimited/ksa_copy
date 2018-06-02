import { compose, applyMiddleware } from 'redux'
import thunkMiddleware from 'redux-thunk'

/* global process */
/* eslint-env  commonjs */
/* eslint-disable global-require */
export default function createEnhancers() {
  const middlewares = [thunkMiddleware]
  // if (process.env.REPORT_TO_EXTERNAL_SERVICES) {
  //   middlewares.unshift(require('shared/raven').crashReporter)
  //   if (typeof window !== 'undefined') {
  //     middlewares.push(require('logrocket').reduxMiddleware())
  //   }
  // }

  return compose(
    applyMiddleware(...middlewares),
    typeof window === 'object' && typeof window.devToolsExtension !== 'undefined'
      ? window.devToolsExtension()
      : (f) => f
  )
}
