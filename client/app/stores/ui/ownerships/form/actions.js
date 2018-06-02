import * as actionTypes from './constants'
import OwnershipEndpoint from 'shared/endpoints/dictionaries/ownership'
import { upsertEntity } from 'stores/common/entities/actions'

export const change = (key, value) => ({
  type: actionTypes.CHANGE,
  key,
  value,
})

const begin = () => ({ type: actionTypes.BEGIN })
// const error = (errors) => ({ type: actionTypes.ERROR, errors })
const failure = () => ({ type: actionTypes.FAILURE })
const success = () => ({ type: actionTypes.SUCCESS })

export const submit = (event) => (dispatch, getState) => {
  event.preventDefault()

  const { shortname, fullname, submiting } = getState().ui.ownerships.form

  if (submiting) return

  const ownership = {
    shortname,
    fullname,
  }

  dispatch(begin())
  OwnershipEndpoint.create({ ownership })
    .then((response) => {
      if (response.success) {
        // dispatch(removeEntity('orgUnits', orgUnit))
        dispatch(upsertEntity('ownerships', response.json))
        dispatch(success())
      } else {
        dispatch(failure())
      }
    })
    .catch(() => dispatch(failure()))
}
