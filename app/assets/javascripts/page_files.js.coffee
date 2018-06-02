document.addEventListener "turbolinks:load", ->
  $('#new_page_file').fileupload
    paramName: 'page_file[wikifile]'
    dataType: 'script'
    add: (e, data) ->
      file = data.files[0]
      data.context = $($.parseHTML(tmpl("template-upload", file))[1])
      $('#new_page_file').append(data.context)
      data.submit()
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
        if data.loaded == data.total
          data.context.delay(5000).fadeOut('slow')
