import React from 'react'
import PropTypes from 'prop-types'

const IconStore = ({ size }) =>
  <svg fill="#000000" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
      <path d="M0 0h24v24H0z" fill="none"/>
      <path d="M20 4H4v2h16V4zm1 10v-2l-1-5H4l-1 5v2h1v6h10v-6h4v6h2v-6h1zm-9 4H6v-4h6v4z"/>
  </svg>

IconStore.propTypes = {
  size: PropTypes.number,
}

IconStore.defaultProps = {
  size: 24,
}

export default IconStore
