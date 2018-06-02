import * as actionTypes from './constants'

export const initialState = {
  shortname: '',
  fullname: '',
  submiting: false,
}

export default (state = initialState, action) => {
  const { type, key, value } = action

  switch (type) {
    case actionTypes.CHANGE:
      return { ...state, [key]: value }

    case actionTypes.BEGIN:
      return { ...state, submiting: true }

    case actionTypes.FAILURE:
      return { ...state, submiting: false }

    case actionTypes.SUCCESS:
      return { ...state, submiting: false, shortname: '', fullname: '' }

    default:
      return state
  }
}
