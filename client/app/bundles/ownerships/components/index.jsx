import React from 'react'
import { Provider } from 'react-redux'

import getStore from 'stores'
import Ownerships from './ownerships'

const DictionaryOwnerships = (props) =>
  <Provider store={getStore()}>
    <Ownerships {...props}/>
  </Provider>


export default DictionaryOwnerships
