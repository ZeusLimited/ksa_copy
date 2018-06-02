search_b2b_classifiers_path = "/tenders/search_b2b_classifiers.json"
get_b2b_classifier_path = "/tenders/get_b2b_classifier.json"

b2bClassifiersFormat = (c) ->
  [c.id, c.name].join(' - ')


document.addEventListener "turbolinks:load", ->
  $('.b2b_classifier_select').select2
    placeholder: "Выберите классификатор"
    minimumInputLength: 4
    multiple: true
    allowClear: true
    ajax:
      quietMillis: 1000
      url: search_b2b_classifiers_path
      dataType: 'json'
      data: (term, page) ->
        q: term
      results: (data, page) ->
        results: data
    initSelection: (element, callback) ->
      add_id = $(element).val()
      $(element).val("")
      if add_id isnt ""
        $.ajax
          url: get_b2b_classifier_path
          data: { classifier_id: add_id }
          dataType: 'json'
        .done (data) -> callback(data)
    formatResult: b2bClassifiersFormat
    formatSelection: b2bClassifiersFormat
