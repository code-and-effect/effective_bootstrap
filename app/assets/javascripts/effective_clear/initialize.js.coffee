$(document).on 'click', 'button[type=clear]', (event) ->
  event.preventDefault()
  $(event.currentTarget).closest('form').trigger('clear')
