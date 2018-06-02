import React from 'react'
import { Provider } from 'react-redux'

import getStore from 'stores'
import EisNumModal from './eis_num_modal'

const EisNumModalForm = (props) =>
  <Provider store={getStore()}>
    <EisNumModal {...props}/>
  </Provider>

export default EisNumModalForm
