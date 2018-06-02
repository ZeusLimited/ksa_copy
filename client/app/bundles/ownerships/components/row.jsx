import React from 'react'
import PropTypes from 'prop-types'

class Row extends React.Component {
  handleToggle = () => {
    const { toggle, ownership } = this.props
    toggle(ownership)
  }

  handleChange = (event) => {
    const { name, value } = event.target
    this.props.change(name, value)
  }

  handleUpdate = (event) => {
    event.preventDefault()
    const { update, ownership, shortname, fullname } = this.props
    update(ownership.id, shortname, fullname)
  }

  handleDelete = (event) => {
    event.preventDefault()
    const { id } = this.props.ownership
    this.props.destroy(id)
  }

  renderEdit = () => {
    const { shortname, fullname } = this.props

    return (
      <tr>
        <td>
          <input type='text'
            name='shortname'
            className='input-block-level'
            onChange={this.handleChange}
            value={shortname}/>
        </td>
        <td>
          <input type='text'
            name='fullname'
            className='input-block-level'
            onChange={this.handleChange}
            value={fullname}/>
        </td>
        <td>
          <button className='btn btn-warning' onClick={this.handleUpdate}>
            Save
          </button>
        </td>
        <td>
          <button className='btn btn-warning' onClick={this.handleToggle}>
            Cancel
          </button>
        </td>
      </tr>
    )
  }

  renderShow = () => {
    const { ownership } = this.props

    return (
      <tr>
        <td>{ownership.shortname}</td>
        <td>{ownership.fullname}</td>
        <td>
          <button className='btn btn-primary' onClick={this.handleToggle}>
            Edit
          </button>
        </td>
        <td>
          <button className='btn btn-warning' onClick={this.handleDelete}>
            Delete
          </button>
        </td>
      </tr>
    )
  }

  render() {
    const { editId, ownership } = this.props
    return editId === ownership.id ? this.renderEdit() : this.renderShow()
  }
}

Row.propTypes = {
  ownership: PropTypes.object.isRequired,
  destroy: PropTypes.func.isRequired,
  toggle: PropTypes.func.isRequired,
  change: PropTypes.func.isRequired,
  update: PropTypes.func.isRequired,
  editId: PropTypes.number,
  shortname: PropTypes.string,
  fullname: PropTypes.string,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { update, change, destroy, toggle } from 'stores/ui/ownerships/row/actions'
import { getOwnership } from 'selectors/ownerships'

const mapStateToProps = (state, props) => {
  const { row } = state.ui.ownerships
  return {
    ownership: getOwnership(state, props),
    shortname: row.shortname,
    fullname: row.fullname,
    editId: row.editId,
  }
}

const mapDispatchToProps = (dispatch) =>
  bindActionCreators({ update, change, destroy, toggle }, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Row)
