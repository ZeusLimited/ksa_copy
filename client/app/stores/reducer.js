import { combineReducers } from 'redux'

// import * as user from './user/'
import * as entities from 'stores/common/entities/'
import * as ui from './ui/'

export const initialStates = {
  // user: user.initialState,
  entities: entities.initialState,
  ui: ui.initialStates,
}

export default combineReducers({
  // user: user.default,
  entities: entities.default,
  ui: ui.default,
})
