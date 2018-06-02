import * as actionTypes from './constants'

export const initialState = {
}

export default (state = initialState, action) => {
  const { type } = action

  switch (type) {
    case actionTypes.BEGIN:
      return { ...state, submiting: true }

    case actionTypes.FAILURE:
      return { ...state, submiting: false }

    case actionTypes.SUCCESS:
      return { ...state, submiting: false }

    default:
      return state
  }
}
