import * as actionTypes from './constants'

export const initialState = {
  num: '',
  id: null,
  submitting: false,
}

export default (state = initialState, action) => {
  const { type, key, value } = action

  switch (type) {
    case actionTypes.CHANGE:
      return { ...state, [key]: value }

    case actionTypes.BEGIN:
      return { ...state, submitting: true }

    case actionTypes.FAILURE:
      return { ...state, submitting: false }

    case actionTypes.SUCCESS:
      return { ...state, submitting: false }

    default:
      return state
  }
}
