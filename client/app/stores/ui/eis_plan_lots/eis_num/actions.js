import * as actionTypes from './constants'
import EisPlanLotEndpoint from 'shared/endpoints/eis_plan_lot'
// import { upsertEntity } from 'stores/common/entities/actions'

export const change = (key, value) => ({
  type: actionTypes.CHANGE,
  key,
  value,
})

const begin = () => ({ type: actionTypes.BEGIN })
// const error = (errors) => ({ type: actionTypes.ERROR, errors })
const failure = () => ({ type: actionTypes.FAILURE })
const success = () => ({ type: actionTypes.SUCCESS })

export const submit = () => (dispatch, getState) => {
  const { id, num, submitting } = getState().ui.eisPlanLots.eisNum

  if (submitting) return

  const eisPlanLot = {
    num,
  }

  dispatch(begin())
  EisPlanLotEndpoint.update(id, { eisPlanLot })
    .then((response) => {
      if (response.success) {
        dispatch(success())
      } else {
        dispatch(failure())
      }
    })
    .catch(() => dispatch(failure()))
}
