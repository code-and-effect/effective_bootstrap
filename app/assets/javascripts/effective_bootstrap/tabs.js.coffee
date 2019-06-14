showTab = ->
  if document.location.hash.length > 0
    $('.nav.nav-tabs').find("a[href='#{document.location.hash}']").tab('show')

$ -> showTab()
$(document).on 'turbolinks:load', -> showTab()