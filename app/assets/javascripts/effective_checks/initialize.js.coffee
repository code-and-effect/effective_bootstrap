$(document).on 'click', '[data-effective-checks-all]', (event) ->
  $(event.currentTarget).closest('.effective-checks').find('input:checkbox').prop('checked', true)
  false

$(document).on 'click', '[data-effective-checks-none]', (event) ->
  $(event.currentTarget).closest('.effective-checks').find('input:checkbox').prop('checked', false)
  false
