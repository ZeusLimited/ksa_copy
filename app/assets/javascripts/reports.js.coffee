winnerFormatResult = (c) ->
  # "<h4 class=\"text-success\">#{c.label}</h4>"
  "#{c.label}"

winnerFormatSelection = (c) ->
  "#{c.label}"

contractor_search_path = "/contractors/search.json"
contractor_info_path = "/contractors/info.json"

@multi_for_winners = ->
  $('#param_report_winners').select2
    placeholder: "Все"
    minimumInputLength: 1
    multiple: true
    allowClear: true
    ajax:
      url: contractor_search_path
      dataType: 'json'
      data: (term, page) ->
        term: term
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      id = $(element).val()
      if id isnt ""
        $.ajax
          url: contractor_info_path
          data: { id: id }
          dataType: 'json'
        .done (data) -> callback(data)
    formatResult: winnerFormatResult
    formatSelection: winnerFormatSelection

$(document).on 'click', '.rep-options', (event) ->
  link = $(this)
  $('#rep_form').load link.data('url'), ->
    $('.reports li.active').removeClass('active')
    link.parent().addClass('active')
    load_defaults($(document))
    add_select_all_clear()
    add_select_all_clear_roots()
    multi_for_contractors()
    multi_for_users()
    multi_for_lot_by_winners()
    agents_commissions_lot_num_select2()

$(document).on 'click', '.rep-old-options', (event) ->
  $('.reports li.active').removeClass('active')
  $(this).parent().addClass('active')
