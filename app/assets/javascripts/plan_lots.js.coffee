control_date = new Date(2016, 0, 1)

tree_okdp_init = ->
  if $('.okdp-control').length > 0
    type = if $.datepicker.parseDate('dd.mm.yy', $('.okdp-control').val()) >= control_date
        'OKPD2'
      else
        'OKDP'
    $("#tree_okdp").dynatree
      initAjax:
        url: '/okdp/nodes_for_parent.json'
        data: { "type": type }
      onLazyRead: (node) ->
        node.appendAjax
          url: '/okdp/nodes_for_parent.json'
          data: { "key": node.data.key, "type": type }

tree_okved_init = ->
  if $('.okved-control').length > 0
    type = if $.datepicker.parseDate('dd.mm.yy', $('.okved-control').val()) >= control_date
        'OKVED2'
      else
        'OKVED'
    $("#tree_okved").dynatree
      initAjax:
        url: '/okveds/nodes_for_parent.json'
        data: { "type": type }
      onLazyRead: (node) ->
        node.appendAjax
          url: '/okveds/nodes_for_parent.json'
          data: { "key": node.data.key, "type": type }

link_select_okdp = ''
link_select_okved = ''

link_select_invest = ''

change_gkpz_state = ->
  if $('#plan_filter_gkpz_state').val() == 'on_date'
    $('.gkpz_on_date').show()
  else
    $('.gkpz_on_date').hide()

disable_select2 = (selector) ->
  $(selector).select2('val', '')
  $(selector).select2('readonly', true)

hide_sme = ->
  disable_select2('#plan_lot_sme_type_id')
  disable_select2('#plan_lot_order1352_id')

show_sme = ->
  $('#plan_lot_sme_type_id').select2('enable', true)
  $('#plan_lot_order1352_id').select2('enable', true)

not_for_sme = ->
  $('#plan_lot_tender_type_id').val() == String($('#plan_lot_tender_type_id').data('unregulated'))

change_sme = ->
  if not_for_sme()
    disable_select2('#plan_lot_sme_type_id')
    disable_select2('#plan_lot_order1352_id')
  else
    $('#plan_lot_sme_type_id').select2('readonly', false)
    $('#plan_lot_order1352_id').select2('readonly', false)

change_tender_type = ->
  change_sme()
  $('#plan_lot_explanations_doc').prop("disabled", $('#plan_lot_tender_type_id').val() != String($('#plan_lot_tender_type_id').data('only-source-id')))
  if $('#plan_lot_tender_type_id').val() == String($('#plan_lot_tender_type_id').data('preselection'))
    $('.annual-limits').find("input:hidden[id$='_destroy']").val('0')
    $('.annual-limits').show()
  else
    $('.annual-limits').find("input:hidden[id$='_destroy']").val('1')
    $('.annual-limits').hide()

$(document).on 'click', "[class|='popover']", (event) ->
  event.preventDefault()

$(document).on 'click', '.select_okdp', (event) ->
  link_select_okdp = $(this)
  $('#select_okdp').modal()
  event.preventDefault()

$(document).on 'click', '.select_okved', (event) ->
  link_select_okved = $(this)
  $('#select_okved').modal()
  event.preventDefault()

$(document).on 'click', '.select_ip', (event) ->
  link_select_invest.closest('div.row').find('.invest-id').val($(this).data('id'))
  link_select_invest.closest('div.row').find('.invest-name').val($(this).data('fullname'))
  $('#invest_rows tr').removeClass('success')
  $(this).closest('tr').addClass('success')
  $('#invest_projects').modal('hide')
  event.preventDefault()

$(document).on 'click', '.select_order1352', (event) ->
  link_select_invest.closest('div.row').find('.order1352-id').val($(this).data('id'))
  link_select_invest.closest('div.row').find('.order1352-fullname').val($(this).data('fullname'))
  $('#order1352').modal('hide')
  event.preventDefault()

$(document).on 'click', '.remove_invest_project', (event) ->
  hidden_field_id = $(this).closest('.row').find('.invest-id')
  input_name = $(this).closest('.row').find('.invest-name')
  hidden_field_id.val('')
  input_name.val('')

$(document).on 'click', '.remove_order1352', (event) ->
  hidden_field_id = $(this).closest('.row').find('.order1352-id')
  input_name = $(this).closest('.row').find('.order1352-fullname')
  hidden_field_id.val('')
  input_name.val('')

$(document).on 'change', 'form #plan_lot_gkpz_year', (event) ->
  $('.specifications').each (i_spec) ->
    reindex_plan_spec_amounts(this)
  $('fieldset.annual-limit').each (i_limit) ->
    $(this).find('.limit-year').val(parseInt($('#plan_lot_gkpz_year').val()) + i_limit)

$(document).on 'change', 'form .customers, #plan_lot_gkpz_year', (event) ->
  customer = $('select.customers').first()
  $('#message_next_number').load(
    customer.data('next-free-number-path'),
    {
      department_id: customer.val(),
      gkpz_year: $('#plan_lot_gkpz_year').val()
    }
  )

$(document).on 'click', '#versoinAll', (event) ->
  $('.version').show()
  $('#versoinAll').addClass('active')
  $('#versoinAgreement').removeClass('active')

$(document).on 'click', '#versoinAgreement', (event) ->
  $('.version').hide()
  $('.not_deleted_version').show()
  $('#versoinAll').removeClass('active')
  $('#versoinAgreement').addClass('active')

$(document).on 'click', 'form .remove_spec_fields', (event) ->
  if $('fieldset.specifications:visible').length > 1
    $(this).closest('fieldset').children('input:hidden').val('1')
    $(this).closest('fieldset').hide 'blind', coloring
  else
    alert 'У лота должна быть хотя бы одна спецификация!'
  event.preventDefault()

$(document).on 'click', 'form .remove-annual-fields', (event) ->
  if $('fieldset.annual-limit:visible').length > 1
    $(this).closest('fieldset').children('input:hidden').val('1')
    $(this).closest('fieldset').hide('blind')
  else
    alert 'У лота должен быть хотя бы один заполненный лимит!'
  event.preventDefault()

$(document).on 'click', 'form .remove_fields', (event) ->
  $(this).closest('fieldset').children("input:hidden[id$='_destroy']").val('1')
  $(this).closest('fieldset').hide 'blind'
  event.preventDefault()

$(document).on 'click', 'form .remove_fias_fields', (event) ->
  if $(this).closest('fieldset.specifications').find('fieldset.fias:visible').length > 1
    $(this).closest('fieldset').children('input:hidden').val('1')
    $(this).closest('fieldset').hide 'blind'
  else
    alert 'У спецификации должен быть хотя бы один адрес поставки!'
  event.preventDefault()

$(document).on 'click', 'form .reform-okved', (event) ->
  event.preventDefault()
  fieldset = $(this).closest('fieldset')
  $.getJSON $(this).data('url'), { okved: fieldset.find('.okved-id').val(), okdp: fieldset.find('.okdp-id').val() }, (data) ->
    fieldset.find('.okdp-id').val(data['okdp_id'])
    fieldset.find('.okdp-name').val(data['okdp_name'])
    fieldset.find('.okved-id').val(data['okved_id'])
    fieldset.find('.okved-name').val(data['okved_name'])
  event.preventDefault()

$(document).on 'change', '.okved-control', (event) ->
  tree_okved_init()
  $("#tree_okved").dynatree("getTree").reload()

$(document).on 'change', '.okdp-control', (event) ->
  tree_okdp_init()
  $("#tree_okdp").dynatree("getTree").reload()

$(document).on 'click', '#btn_reset_filter_okdp', (event) ->
  $('#filter_okdp').val('')
  tree_okdp_init()
  $("#tree_okdp").dynatree("getTree").reload()

$(document).on 'click', '#btn_reset_filter_okved', (event) ->
  $('#filter_okved').val('')
  tree_okved_init()
  $("#tree_okved").dynatree("getTree").reload()

$(document).on 'click', '#btn_filter_okdp', (event) ->
  filter = $('#filter_okdp').val()
  if filter.length < 3
    alert 'Введите минимум 3 символа.'
  else
    type = if $.datepicker.parseDate('dd.mm.yy', $('.okdp-control').val()) >= control_date
        'OKPD2'
      else
        'OKDP'
    $("#tree_okdp").dynatree
      initAjax:
        url: '/okdp/nodes_for_filter.json'
        data: { "filter": filter, "type": type }
    $("#tree_okdp").dynatree("getTree").reload()

$(document).on 'click', '#btn_filter_okved', (event) ->
  filter = $('#filter_okved').val()
  if filter.length < 2
    alert 'Введите минимум 2 символа.'
  else
    type = if $.datepicker.parseDate('dd.mm.yy', $('.okved-control').val()) >= control_date
        'OKVED2'
      else
        'OKVED'
    $("#tree_okved").dynatree
      initAjax:
        url: '/okveds/nodes_for_filter.json'
        data: { "filter": filter, "type": type }
    $("#tree_okved").dynatree("getTree").reload()

$(document).on 'click', '#btn_select_okdp', (event) ->
  node = $("#tree_okdp").dynatree("getActiveNode")
  if node
    if node.getLevel() <= 2
      alert 'Первый и второй уровни выбирать нельзя, выберите раздел уровнём ниже.'
    else
      link_select_okdp.closest('div.row').find('.okdp-id').val(node.data.key)
      link_select_okdp.closest('div.row').find('.okdp-name').val(node.data.title)
      $('#select_okdp').modal('hide')
  else
    alert 'Вы не выбрали ни одного варианта.'

$(document).on 'click', '#btn_select_okved', (event) ->
  node = $("#tree_okved").dynatree("getActiveNode")
  if node
    if node.data.isRoot
      alert 'Первый уровень выбирать нельзя, выберите раздел уровнём ниже.'
    else
      link_select_okved.closest('div.row').find('.okved-id').val(node.data.key)
      link_select_okved.closest('div.row').find('.okved-name').val(node.data.title)
      $('#select_okved').modal('hide')
  else
    alert 'Вы не выбрали ни одного варианта.'

$(document).on 'change', '#plan_lot_department_id', (event) ->
  $('#plan_lot_commission_id').select2("val", "")
  $('#plan_lot_commission_id').empty()
  $('#plan_lot_commission_id').append($('<option value=""></option>'))
  $.getJSON $(this).data('url'), { org_id: $(this).val() }, (data) ->
    $.each data, (key, val) ->
      $('#plan_lot_commission_id').append($('<option></option>').attr('value', val.id).text(val.name))

$(document).on 'click', '#filter_invest_projects', (event) ->
  params =
    year: $('#plan_lot_gkpz_year').val()
    department: $('#invest_department').val()
    invest_id: link_select_invest.closest('div.row').find('.invest-id').val()
  $('#invest_rows').load($(this).data('filter-url'), params)
  event.preventDefault()

$(document).on 'click', 'form .show-invest-dialog', (event) ->
  link_select_invest = $(this)
  event.preventDefault()

# TODO Fast bug fix. Разобраться с этим, в чем разница и почему не работает
# $(document).on 'change', '#plan_lot_tender_type_id', (event) ->
#   change_tender_type()
#   change_regulation_item $(this).data('url')
#
# $(document).on 'change', '#plan_lot_etp_address_id', (event) ->
#   change_sme()
#
# $(document).on 'change', 'select.customers', (event) ->
#   change_regulation_item $(this).data('url')
#
# $(document).on 'change', '#plan_lot_regulation_item_id', (event) ->
#   change_order1352_item $(this).data('url')
#
document.addEventListener "turbolinks:load", ->
  load_defaults($(document))

  $("[class|='popover']").popover()

  change_gkpz_state()
  $('#plan_filter_gkpz_state').change change_gkpz_state

  tree_okdp_init()
  tree_okved_init()
  coloring()
  $('#plan_lot_plan_specifications_attributes_0_customer_id').trigger('change')

  $('fieldset.specifications').each (i) ->
    visible_last_year_delete($(this))

  $('#filter_okdp').keydown (event) ->
    if event.keyCode == 13
      event.preventDefault()
      $('#btn_filter_okdp').click()

  $('#filter_okved').keydown (event) ->
    if event.keyCode == 13
      event.preventDefault()
      $('#btn_filter_okved').click()

  $('#plan_lot_tender_type_id').change ->
    change_tender_type()
    change_regulation_item $(this).data('url')

  $('#plan_lot_etp_address_id').change ->
    change_sme()

  $('select.customers').change ->
    change_regulation_item $(this).data('url')

  $('#plan_lot_regulation_item_id').change ->
    change_order1352_item $(this).data('url')

  change_regulation_item = (url) ->
    $('#plan_lot_regulation_item_id').select2("val", "")
    $('#plan_lot_regulation_item_id').empty()
    $('#plan_lot_regulation_item_id').append($('<option value=""></option>'))
    $.getJSON url, { tender_type_id: $('#plan_lot_tender_type_id').val(), department_id: $('select.customers').first().val() }, (data) ->
      $.each data, (key, val) ->
        $('#plan_lot_regulation_item_id').append($('<option></option>').attr('value', val.id).text(val.num))

  change_order1352_item = (url) ->
    $('#plan_lot_order1352_id').select2("val", "")
    $('#plan_lot_order1352_id').empty()
    $('#plan_lot_order1352_id').append($('<option value=""></option>'))
    $.getJSON url, { regulation_item: $('#plan_lot_regulation_item_id').val() }, (data) ->
      $.each data, (key, val) ->
        $('#plan_lot_order1352_id').append($('<option></option>').attr('value', val.ref_id).text(val.fullname))

  change_tender_type()
  # change_regulation_item($('#plan_lot_tender_type_id').data('url'))
