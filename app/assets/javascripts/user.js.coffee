# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Для интеграции с доменом
# $(document).on 'click', '#user_ldap', (event) ->
#   $.getJSON $(this).data('url'), (data) ->
#     if data['samaccountname'] != undefined
#       fio = data['name'].split(" ")
#       $('#user_login').val(data['samaccountname'])
#       $('#user_user_job').val(data['title'])
#       $('#user_surname').val(fio[0])
#       $('#user_name').val(fio[1])
#       $('#user_patronymic').val(fio[2])
#       $('#user_phone_office').val(data['telephonenumber'])
#       $('#user_phone_public').val(data['othertelephone'])
#       $('#user_phone_cell').val(data['mobile'])
#     else
#       alert('Не удалось получить данные из домена. Проверьте правильность адреса электронной почты')
#   event.preventDefault()
