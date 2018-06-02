import { compose, createStore } from 'redux'
// import throttle from 'lodash/throttle'

import reducers from './reducer'
import createEnhancers from 'shared/store'
import getInitialState from './hydrator'

/* eslint-env commonjs */
/* eslint-disable global-require */
export default (props, railsContext) => {

  let enhancer = null
  if (railsContext.serverSide) {
    enhancer = compose()
  } else {
    enhancer = createEnhancers()
  }

  const store = createStore(reducers, getInitialState(props), enhancer)

  if (module.hot) {
    module.hot.accept('./reducer', () => {
      store.replaceReducer(require('./reducer').default)
    })
  }

  return store
}
