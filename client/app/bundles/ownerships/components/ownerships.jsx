import React from 'react'
import PropTypes from 'prop-types'

import Form from './form'
import Table from './table'

class Ownerships extends React.Component {
  render() {
    return (
      <div>
        <Form/>
        <Table/>
      </div>
    )
  }
}

Ownerships.propTypes = {
  ownerships: PropTypes.array.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { getArrayOwnerships } from 'selectors/ownerships'

const mapStateToProps = (state) => ({
  ownerships: getArrayOwnerships(state),
})

const mapDispatchToProps = (dispatch) => bindActionCreators({}, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Ownerships)
