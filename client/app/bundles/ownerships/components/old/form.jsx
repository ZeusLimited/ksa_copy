import React from 'react';

const Form extends React.Component (
  constructor(props) {
    super()
    this.state = { shortname: '', fullname: ''  }
  }

  valid() {
    this.state.shortname && this.state.fullname
  }

  handleChange(event) {
    this.props.onChange({ event.target.name: event.target.value })
  }

  handleSubmit(event) {
    event.preventDefault()
    $.post '', { ownership: @state }, (data) =>
      @props.handleNewRecord data
      @setState @getInitialState()
    , 'JSON'
  }

  render () {
    <form onSubmit=''>
      <div className='row'>
        <div className='span2'>
          <input
            type='text'
            placeholder='Краткое наименование'
            name='shortname'
            className='input-block-level'
            value={this.state.shortname}
            onChange={this.handleChange} />
        </div>
        <div className='span5'>
          <input
            type='text'
            placeholder='Полное наименование'
            className='input-block-level'
            value={this.state.fullname}
            onChange={this.handleChange} />
        </div>
        <div className='span2'>
          <button
            type='submit'
            className='btn btn-primary input-block-level'
            disabled={!this.valid}>
            Создать
          </button>
        </div>
      </div>
    </form>
  }
);

export Form;
