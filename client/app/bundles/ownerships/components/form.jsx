import React from 'react'
import PropTypes from 'prop-types'

class Form extends React.Component {
  valid = () => {
    const { shortname, fullname, submiting } = this.props
    return shortname && fullname && !submiting
  }

  handleChange = (event) => {
    const { name, value } = event.target
    this.props.change(name, value)
  }

  render() {
    const { shortname, fullname, submit, submiting } = this.props
    return (
      <form onSubmit={submit}>
        <div className='row'>
          <div className='span2'>
            <input type='text'
              placeholder='Краткое наименование'
              name='shortname'
              value={shortname}
              onChange={this.handleChange}
              className='input-block-level'/>
          </div>
          <div className='span5'>
            <input type='text'
              placeholder='Полное наименование'
              value={fullname}
              onChange={this.handleChange}
              name='fullname'
              className='input-block-level'/>
          </div>
          <div className='span2'>
            <button type='submit'
              className='btn btn-primary input-block-level'
              disabled={!this.valid()}>
              {submiting ? 'Выполняется' : 'Создать'}
            </button>
          </div>
        </div>
      </form>
    )
  }
}

Form.propTypes = {
  shortname: PropTypes.string.isRequired,
  fullname: PropTypes.string.isRequired,
  submiting: PropTypes.bool.isRequired,
  submit: PropTypes.func.isRequired,
  change: PropTypes.func.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { change, submit } from 'stores/ui/ownerships/form/actions'

const mapStateToProps = (state) => {
  const { form } = state.ui.ownerships

  return {
    shortname: form.shortname,
    fullname: form.fullname,
    submiting: form.submiting,
  }
}

const mapDispatchToProps = (dispatch) => bindActionCreators({ change, submit }, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Form)
