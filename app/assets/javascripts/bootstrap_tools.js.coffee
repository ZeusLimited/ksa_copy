document.addEventListener "turbolinks:load", ->
  default_classes = { classes: { "ui-tooltip": "ui-corner-all" }}
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip(default_classes)
  $("a[rel=tooltip]").tooltip(default_classes)
  $('a').tooltip(default_classes)
