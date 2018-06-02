import React from 'react';

const Index extends React.Component {
  constructor() {
    super()
    this.state = { records: this.props.data }
  }

  getDefaultProps() {
    this.setState(records: [])
  }

  addRecord(record) {
    let records = this.state.records.slice()
    records.push record // Use Redux Or Not?
    this.setState(records: records)
  }
  deleteRecord(record, data) {
    let records = @state.records.slice()
    let index = records.indexOf record
    records.splice index, 1 // Use Redux Or Not?
    this.replaceState(records: records)
  }

  updateRecord(record, data) {
    let index = @state.records.indexOf record
    records = React.addons.update(@state.records, { $splice: [[index, 1, data]] }) // Update
    this.replaceState(records: records)
  }

  render() {
    let items = this.state.records
    return(
      <div className='records'>
        <Form handleNewRecord={this.addRecord} />
        <hr />
        <table className: 'table table-bordered'>
          <thead>
            <tr>
              <th>Краткое наименование</th>
              <th>Полное наименование</th>
              <th className: 'column-btn' />
              <th className: 'column-btn' />
            </tr>
          </thead>
          <tbody>
            {items.map(item =>
              <Row key={item.id}
                   record={record}
                   handleDeleteRecord={this.deleteRecord}
                   handleEditRecord={this.updateRecord} />)}
          </tbody>
        </table>
      </div>
    )
  }
};
