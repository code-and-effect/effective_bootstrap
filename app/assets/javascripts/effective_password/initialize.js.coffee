# Prevent non-currency buttons from being pressed
$(document).on 'click', 'span[data-effective-password]', (event) ->
  $obj = $(event.currentTarget)
  $input = $obj.closest('.input-group')

  $input.find('input').attr('type', $obj.data('effective-password'))
  $input.find('span[data-effective-password]').toggle()

  false
