import React from 'react'
import PropTypes from 'prop-types'

class Expert extends React.Component {
  render() {
    const { expert } = this.props
    return (
      <tr>
        <td>{expert.user.fioFull}</td>
        <td>{expert.destinationNames}</td>
      </tr>
    )
  }
}


Expert.propTypes = {
  expert: PropTypes.object.isRequired,
}

import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import { getExpert } from 'selectors/experts'

const mapStateToProps = (state, props) => ({
  expert: getExpert(state, props),
})

const mapDispatchToProps = (dispatch) =>
  bindActionCreators({}, dispatch)

export default connect(mapStateToProps, mapDispatchToProps)(Expert)
