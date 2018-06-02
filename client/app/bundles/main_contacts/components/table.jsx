import React from 'react'
import PropTypes from 'prop-types'

import SortableBody from './sortable_body'

export default class Table extends React.Component {
  render() {
    const { contactType } = this.props
    return (
      <table className='table table-bordered'>
        <thead>
          <tr>
            <th className='col1'>ФИО</th>
            <th className='col1'>Должность</th>
            <th className='col2'>Контактные телефоны</th>
            <th className='col3'>e-mail</th>
            <th className='col4'></th>
          </tr>
        </thead>
        <SortableBody contactType={contactType}/>
      </table>
    )
  }
}

Table.propTypes = {
  contactType: PropTypes.string.isRequired,
}
