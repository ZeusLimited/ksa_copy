document.addEventListener "turbolinks:load", ->
  if $('.pagination-scroll').length
    $(window).scroll ->
      url = $('.pagination-scroll .next_page').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 100
        $('.pagination-scroll').text("Загрузка следующей страницы...")
        $.getScript(url)
    $(window).scroll()
