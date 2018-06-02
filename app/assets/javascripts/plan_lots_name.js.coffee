$(document).on 'blur', '#plan_lot_lot_name.main_form', (event) ->
  if (confirm("Вы хотите скопировать наименование в первую спецификацию?"))
    $('#plan_lot_plan_specifications_attributes_0_name').val($(this).val())
