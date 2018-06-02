$(document).on 'click', '.remove-files', (event) ->
  $(this).closest("tr").children('input:hidden').val('1')
  $(this).closest('tr').hide()
  event.preventDefault()

document.addEventListener "turbolinks:load", ->

  $('.file_upload').fileupload
    paramName: 'tender_file[document]'
    dataType: 'script'
    add: (e, data) ->
      types = /(\.|\/)(docx|doc|rtf|xlsx|xls|pdf|jpg|jpeg|tif|tiff|eml|rar|zip|txt|7z|tar|gz)$/i
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        data.context = $(tmpl("template-upload", file).trim()) if $('#template-upload').length > 0
        $('.loaded_files').append(data.context)
        data.submit()
      else
        alert "Файл '#{file.name}' прикрепить нельзя.\n" +
          "Прикреплять можно только файлы следующих типов:\n" +
          "docx doc rtf xlsx xls pdf jpg jpeg tif tiff eml rar zip txt 7z png ppt pptx tar gz"
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
        if data.loaded == data.total
          data.context.delay(3000).fadeOut('slow')
