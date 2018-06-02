import React from 'react'
import PropTypes from 'prop-types'

import Row from './row'

class Table extends React.Component {

  render() {
    const { ownerships } = this.props
    return (
      <table className='table table-bordered'>
        <thead>
          <tr>
            <th>Краткое наименование</th>
            <th>Полное наименование</th>
            <th className='column-btn' />
            <th className='column-btn' />
          </tr>
        </thead>
        <tbody>
          {ownerships.map((ownership) =>
            <Row key={ownership.id} ownershipId={ownership.id} />
          )}
        </tbody>
      </table>
    )
  }
}

Table.propTypes = {
  ownerships: PropTypes.array.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { getArrayOwnerships } from 'selectors/ownerships'

const mapStateToProps = (state) => ({
  ownerships: getArrayOwnerships(state),
})

const mapDispatchToProps = (dispatch) => bindActionCreators({}, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Table)
