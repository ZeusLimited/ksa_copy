import React from 'react'
import PropTypes from 'prop-types'

import { Button } from 'shared/components'

class EisNumModal extends React.Component {
  handleChange = (event) => {
    const { name, value } = event.target
    this.props.change(name, value)
  }

  onSubmit = (event) => {
    const { submit } = this.props
    event.preventDefault()
    submit()
  }

  render() {
    const { num, submitting } = this.props
    return (
      <div id='eis_num_modal' className='modal hide fade'>
        <div className='modal-header'>
          <button type='button' className='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
          <h3>Номер позиции плана на ЕИС</h3>
        </div>
        <form onSubmit={this.onSubmit}>
          <div className='modal-body'>
            <input type='text'
              placeholder='Номер на ЕИС'
              disabled={submitting}
              name='num'
              value={num}
              onChange={this.handleChange}
              className='input-block-level'/>
            {submitting && <small>Идет сохранение...</small>}
          </div>
          <div className='modal-footer'>
            <Button title='Сохранить' className='btn btn-primary' loading={submitting} type='submit'/>
          </div>
        </form>
      </div>
    )
  }
}

EisNumModal.propTypes = {
  submitting: PropTypes.bool.isRequired,
  num: PropTypes.string.isRequired,
  submit: PropTypes.func.isRequired,
  change: PropTypes.func.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { submit, change } from 'stores/ui/eis_plan_lots/eis_num/actions'

const mapStateToProps = (state) => {
  const { eisNum } = state.ui.eisPlanLots
  return {
    num: eisNum.num,
    submitting: eisNum.submitting,
  }
}

const mapDispatchToProps = (dispatch) => bindActionCreators({ submit, change }, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(EisNumModal)
