$(document).on 'change', '.effective-radios input', (event) ->
  $input = $(event.currentTarget)
  $group = $input.closest('.effective-radios')

  return unless ($group.hasClass('is-valid') || $group.hasClass('is-invalid'))

  if $input.is(':valid')
    $group.addClass('is-valid').removeClass('is-invalid')
  else
    $group.addClass('is-invalid').removeClass('is-valid')

