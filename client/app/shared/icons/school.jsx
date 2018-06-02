import React from 'react'
import PropTypes from 'prop-types'

const IconSchool = ({ size }) =>
  <svg fill='#000000' height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
      <path d="M0 0h24v24H0z" fill="none"/>
      <path d="M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82zM12 3L1 9l11 6 9-4.91V17h2V9L12 3z"/>
  </svg>

IconSchool.propTypes = {
  size: PropTypes.number,
}

IconSchool.defaultProps = {
  size: 24,
}

export default IconSchool