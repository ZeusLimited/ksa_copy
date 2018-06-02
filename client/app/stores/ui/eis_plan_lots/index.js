import { combineReducers } from 'redux'

import * as form from './eis_num'

export const initialStates = {
  eisNum: form.initialState,
}

export default combineReducers({
  eisNum: form.default,
})
