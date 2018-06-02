import React from 'react'
import PropTypes from 'prop-types'

import Row from './row'

class SortableBody extends React.Component {
  // onReorder: (records) ->
  //   @props.rerender records
  // componentWillUpdate: ->
  //   $(ReactDOM.findDOMNode(@)).sortable 'destroy'
  // componentWillUnmount: ->
  //   $(ReactDOM.findDOMNode(@)).sortable 'destroy'
  // componentDidUpdate: ->
  //   $(ReactDOM.findDOMNode(@)).disableSelection()
  //   $(ReactDOM.findDOMNode(@)).sortable axis: 'y', stop: =>
  //       items = []
  //       for id1 in $(ReactDOM.findDOMNode(@)).sortable("toArray")
  //         id = parseInt(id1.replace(/^item-/, ""))
  //         nextItem = @props.items.find (item) ->
  //           item.id == id
  //         items.push nextItem
  //       $(ReactDOM.findDOMNode(@)).sortable 'cancel'
  //       @onReorder items
  // componentDidMount: ->
  //   $(ReactDOM.findDOMNode(@)).disableSelection()
  //   $(ReactDOM.findDOMNode(@)).sortable axis: 'y', stop: =>
  //       items = []
  //       for id1 in $(ReactDOM.findDOMNode(@)).sortable("toArray")
  //         id = parseInt(id1.replace(/^item-/, ""))
  //         nextItem = @props.items.find (item) ->
  //           item.id == id
  //         items.push nextItem
  //       $(ReactDOM.findDOMNode(@)).sortable 'cancel'
  //       @onReorder items

  render() {
    const { contacts } = this.props
    return (
      <tbody>
        {contacts.map((contact) =>
          <Row key={contact.id} contactId={contact.id}/>
        )}
      </tbody>
    )
  }
}

SortableBody.propTypes = {
  contacts: PropTypes.array.isRequired,
  contactType: PropTypes.string.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { getArrayContactsByType } from 'selectors/contacts'

const mapStateToProps = (state, props) => ({
  contacts: getArrayContactsByType(state, props),
})

const mapDispatchToProps = (dispatch) => bindActionCreators({}, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(SortableBody)
