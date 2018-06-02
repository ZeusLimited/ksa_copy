import React from 'react';

const Row extends React.Component {
  constructor() {
    super()
    this.state = { edit: false }
  }

  handleToggle(event) {
    event.preventDefault();
    this.setState(edit: !this.state.edit)
  }

  handleDelete(event) {
    event.preventDefault();
    $.ajax
      method: 'DELETE'
      url: "/ownerships/#{ @props.record.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteRecord @props.record
  }

  handleEdit(event) {
    event.preventDefault();
    data =
      shortname: ReactDOM.findDOMNode(@refs.shortname).value
      fullname: ReactDOM.findDOMNode(@refs.fullname).value
    $.ajax
      method: 'PUT'
      url: "/ownerships/#{ @props.record.id }"
      dataType: 'JSON'
      data:
        ownership: data
      success: (data) =>
        @setState edit: false
        @props.handleEditRecord @props.record, data
  }

  render() {
    {if this.state.edit
      <EditRowOwnership />
    else
      <OwnershipAttributes />
    }
  }
};

Row.propTypes = {
  record: ,
  handleDeleteRecord: PropTypes.func.isRequired,
  handleEditRecord: PropTypes.func.isRequired,
};




@Ownership = React.createClass

  recordRow: ->
    React.DOM.tr null,
      React.DOM.td null, @props.record.shortname
      React.DOM.td null, @props.record.fullname
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-primary'
          onClick: @handleToggle
          'Изменить'
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-danger'
          onClick: @handleDelete
          'Удалить'

  recordForm: ->
        React.DOM.tr null,
          React.DOM.td null,
            React.DOM.input
              className: 'input-block-level'
              type: 'text'
              defaultValue: @props.record.shortname
              ref: 'shortname'
          React.DOM.td null,
            React.DOM.input
              className: 'input-block-level'
              type: 'text'
              defaultValue: @props.record.fullname
              ref: 'fullname'
          React.DOM.td null,
            React.DOM.a
              className: 'btn btn-success'
              onClick: @handleEdit
              'Сохранить'
          React.DOM.td null,
            React.DOM.a
              className: 'btn btn-warning'
              onClick: @handleToggle
              'Отменить'
  render: ->
    if @state.edit
      @recordForm()
    else
      @recordRow()
