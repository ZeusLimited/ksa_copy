import * as actionTypes from './constants'

export const mergeEntities = (entities) => ({ type: actionTypes.MERGE_ENTITIES, entities })
export const upsertEntity = (key, entity, idAttribute = 'id') =>
  ({ type: actionTypes.UPSERT_ENTITY, key, entity, idAttribute })
export const removeEntity = (key, id) => ({ type: actionTypes.REMOVE_ENTITY, key, id })
