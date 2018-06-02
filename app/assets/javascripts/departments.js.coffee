tree_list_init = ->
  $("#tree_list").dynatree
    initAjax:
      url: '/departments/nodes_for_index.json'
    onActivate: ->
      window.open(node.data.href, '_top')

document.addEventListener "turbolinks:load", ->
  tree_list_init()
