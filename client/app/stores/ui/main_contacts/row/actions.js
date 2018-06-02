import * as actionTypes from './constants'
import MainContactEndpoint from 'shared/endpoints/dictionaries/main_contact'
import { removeEntity } from 'stores/common/entities/actions'

const begin = () => ({ type: actionTypes.BEGIN })
// const error = (errors) => ({ type: actionTypes.ERROR, errors })
const failure = () => ({ type: actionTypes.FAILURE })
const success = () => ({ type: actionTypes.SUCCESS })

export const destroy = (id) => (dispatch) => {
  dispatch(begin())
  MainContactEndpoint.destroy(id)
    .then((response) => {
      if (response.success) {
        dispatch(removeEntity('contacts', id))
        dispatch(success())
      } else {
        dispatch(failure())
      }
    })
    .catch(() => dispatch(failure()))
}
