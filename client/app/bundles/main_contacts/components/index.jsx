import React from 'react'
import { Provider } from 'react-redux'

import getStore from 'stores'
import Contacts from './contacts'

const MainContacts = (props) =>
  <Provider store={getStore()}>
    <Contacts {...props}/>
  </Provider>


export default MainContacts
