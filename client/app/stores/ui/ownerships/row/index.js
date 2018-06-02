import * as actionTypes from './constants'

export const initialState = {
  editId: null,
  shortname: '',
  fullname: '',
}

const toggle = (state, action) => {
  const { id, shortname, fullname } = action
  return {
    ...state,
    editId: state.editId === id ? null : id,
    shortname,
    fullname,
  }
}

export default (state = initialState, action) => {
  const { type, id, key, value } = action

  switch (type) {
    case actionTypes.CHANGE:
      return { ...state, [key]: value }

    case actionTypes.TOGGLE:
      return toggle(state, action)

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
