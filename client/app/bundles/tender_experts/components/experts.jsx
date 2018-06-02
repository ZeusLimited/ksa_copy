import React from 'react'
import PropTypes from 'prop-types'

import Expert from './expert'

class Experts extends React.Component {
  render() {
    const { experts } = this.props
    return (
      <table className='table table-bordered'>
        <thead>
          <tr>
            <th>ФИО Эксперта</th>
            <th>Критерии оценки</th>
          </tr>
        </thead>
        <tbody>
          {experts.map((expert) =>
            <Expert key={expert.id} expertId={expert.id}/>
          )}
        </tbody>
      </table>
    )
  }
}

Experts.propTypes = {
  experts: PropTypes.array.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { getArrayExperts } from 'selectors/experts'

const mapStateToProps = (state) => ({
  experts: getArrayExperts(state),
})

const mapDispatchToProps = (dispatch) => bindActionCreators({}, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Experts)
