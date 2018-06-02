import { combineReducers } from 'redux'

import * as form from './form'
import * as row from './row'

export const initialStates = {
  form: form.initialState,
  row: row.initialState,
}

export default combineReducers({
  form: form.default,
  row: row.default,
})
