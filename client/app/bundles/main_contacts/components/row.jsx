import React from 'react'
import PropTypes from 'prop-types'

class Row extends React.Component {

  handleDelete = (event) => {
    event.preventDefault()
    const { contactId } = this.props
    this.props.destroy(contactId)
  }

  render() {
    const { user } = this.props
    return (
      <tr>
        <td className='col1'>{user.fioFull}</td>
        <td className='col2'>{user.userJob}</td>
        <td className='col2'>{user.phone}</td>
        <td className='col3'>{user.email}</td>
        <td className='col4'>
          <a className='icon-trash' title='Удалить' onClick={this.handleDelete}/>
        </td>
      </tr>
    )
  }
}

Row.propTypes = {
  contact: PropTypes.object.isRequired,
  user: PropTypes.object.isRequired,
  contactId: PropTypes.number.isRequired,
  destroy: PropTypes.func.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { destroy } from 'stores/ui/main_contacts/row/actions'
import { getUser } from 'selectors/users'
import { getContact } from 'selectors/contacts'

const mapStateToProps = (state, props) => ({
  contact: getContact(state, props),
  user: getUser(state, props),
})

const mapDispatchToProps = (dispatch) =>
  bindActionCreators({ destroy }, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Row)
