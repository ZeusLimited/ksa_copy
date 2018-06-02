import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'

export default class Button extends React.Component {
  render() {
    const { title, type, className, disabled, loading, onClick } = this.props
    const buttonClass = classNames('button', className, { loading, disabled })
    return (
      <button type={type} className={buttonClass} disabled={disabled || loading} onClick={onClick}>
        <div className='loading-background'/>
        {title}
      </button>
    )
  }
}

Button.propTypes = {
  title: PropTypes.string.isRequired,
  type: PropTypes.string,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  loading: PropTypes.bool,
  onClick: PropTypes.func,
}

Button.defaultProps = {
  type: 'button',
  loading: false,
  disabled: false,
}
