import React from 'react'
import PropTypes from 'prop-types'

import Table from './table'

export default class Contacts extends React.Component {
  render() {
    return (
      <div>
        <h3>ИНФОРМАЦИОННО-МЕТОДОЛОГИЧЕСКАЯ ПОДДЕРЖКА</h3>
        <Table contactType='organizer'/>
        <h3>ТЕХНИЧЕСКАЯ ПОДДЕРЖКА</h3>
        <Table contactType='developer'/>
      </div>
    )
  }
}

// Contacts.propTypes = {
//   contacts: PropTypes.array.isRequired,
// }
//
// import { connect } from 'react-redux'
// import { bindActionCreators } from 'redux'
//
// import { getArrayContacts } from 'selectors/contacts'
//
// const mapStateToProps = (state, props) => ({
//   contacts: getArrayContacts(state, props),
// })
//
// const mapDispatchToProps = (dispatch) => bindActionCreators({}, dispatch)
//
// export default connect(mapStateToProps, mapDispatchToProps)(Contacts)
