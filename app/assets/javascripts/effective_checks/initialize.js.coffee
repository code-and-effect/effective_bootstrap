$(document).on 'click', '[data-effective-checks-all]', (event) ->
  $(event.currentTarget).closest('.effective-checks').find('input:checkbox:enabled:not([readonly])').prop('checked', true)
  false

$(document).on 'click', '[data-effective-checks-none]', (event) ->
  $(event.currentTarget).closest('.effective-checks').find('input:checkbox:enabled:not([readonly])').prop('checked', false)
  false
