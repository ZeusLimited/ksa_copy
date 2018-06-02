import React from 'react'
import { Provider } from 'react-redux'

import getStore from 'stores'
import Experts from './experts'

const TenderExperts = (props) =>
  <Provider store={getStore()}>
    <Experts {...props}/>
  </Provider>


export default TenderExperts
