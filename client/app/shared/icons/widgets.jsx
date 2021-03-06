import React from 'react'
import PropTypes from 'prop-types'

const IconWidgets = ({ size }) =>
  <svg fill="#000000" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
      <path d="M13 13v8h8v-8h-8zM3 21h8v-8H3v8zM3 3v8h8V3H3zm13.66-1.31L11 7.34 16.66 13l5.66-5.66-5.66-5.65z"/>
      <path d="M0 0h24v24H0z" fill="none"/>
  </svg>

IconWidgets.propTypes = {
  size: PropTypes.number,
}

IconWidgets.defaultProps = {
  size: 24,
}

export default IconWidgets
