$(document).on 'click', '[data-effective-checks-all]', (event) ->
  $(event.currentTarget).closest('.effective-checks').find('input:checkbox:enabled:not([readonly])').prop('checked', true)
  false

$(document).on 'click', '[data-effective-checks-none]', (event) ->
  $(event.currentTarget).closest('.effective-checks').find('input:checkbox:enabled:not([readonly])').prop('checked', false)
  false

$(document).on 'change', '.was-validated .effective-checks-required', (event) ->
  if $(@).find('input:checked').length > 0
    $(@).addClass('is-valid').removeClass('is-invalid')
  else
    $(@).addClass('is-invalid').removeClass('is-valid')
