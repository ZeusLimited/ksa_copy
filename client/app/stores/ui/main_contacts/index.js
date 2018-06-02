import { combineReducers } from 'redux'

import * as row from './row'

export const initialStates = {
  row: row.initialState,
}

export default combineReducers({
  row: row.default,
})
