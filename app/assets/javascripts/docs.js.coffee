$(document).on 'click', '.link-to-structure', (event) ->
  $(this).closest('.blog-post').find('.structure').load $(this).data('url')
  event.preventDefault()
