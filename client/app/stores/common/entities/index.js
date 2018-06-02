import each from 'lodash/each'
import omit from 'lodash/omit'
import clone from 'lodash/clone'

import * as actionTypes from './constants'

export const initialState = {
  ownerships: {},
  experts: {},
  users: {},
  contacts: {},
  eisPlanLots: {},
}

function mergeEntities(state, entities) {
  const newState = clone(state)
  each(entities, (values, key) => {
    newState[key] = { ...newState[key], ...values }
  })
  return newState
}

export default (state = initialState, action = null) => {
  const { type, entities, key, entity, idAttribute, id } = action

  switch (type) {
    case actionTypes.MERGE_ENTITIES:
      return mergeEntities(state, entities)

    case actionTypes.UPSERT_ENTITY:
      return { ...state, [key]: { ...state[key], [entity[idAttribute]]: entity } }

    case actionTypes.REMOVE_ENTITY:
      return { ...state, [key]: omit(state[key], id) }

    default:
      return state
  }
}
