import { combineReducers } from 'redux'

import * as ownerships from './ownerships'
import * as contacts from './main_contacts'
import * as eisPlanLots from './eis_plan_lots'

export const initialStates = {
  ownerships: ownerships.initialStates,
  contacts: contacts.initialState,
  eisPlanLots: eisPlanLots.initialStates,
}

export default combineReducers({
  ownerships: ownerships.default,
  contacts: contacts.default,
  eisPlanLots: eisPlanLots.default,
})
