import * as actionTypes from './constants'
import OwnershipEndpoint from 'shared/endpoints/dictionaries/ownership'
import { upsertEntity, removeEntity } from 'stores/common/entities/actions'

export const change = (key, value) => ({
  type: actionTypes.CHANGE,
  key,
  value,
})

export const toggle = ({ id, shortname, fullname }) => ({
  type: actionTypes.TOGGLE,
  id,
  shortname,
  fullname,
})

const begin = () => ({ type: actionTypes.BEGIN })
// const error = (errors) => ({ type: actionTypes.ERROR, errors })
const failure = () => ({ type: actionTypes.FAILURE })
const success = () => ({ type: actionTypes.SUCCESS })

export const destroy = (id) => (dispatch) => {
  dispatch(begin())
  OwnershipEndpoint.destroy(id)
    .then((response) => {
      if (response.success) {
        dispatch(removeEntity('ownerships', id))
        dispatch(success())
      } else {
        dispatch(failure())
      }
    })
    .catch(() => dispatch(failure()))
}

export const update = (id, shortname, fullname) => (dispatch) => {
  const ownership = {
    id,
    shortname,
    fullname,
  }

  OwnershipEndpoint.update(id, ownership)
    .then((response) => {
      if (response.success) {
        dispatch(upsertEntity('ownerships', ownership))
        dispatch(success())
        dispatch(toggle(ownership))
      } else {
        dispatch(failure())
      }
    })
    .catch(() => dispatch(failure()))
}
