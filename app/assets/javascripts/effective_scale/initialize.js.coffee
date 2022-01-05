# Prevent non-numeric buttons from being pressed
$(document).on 'keydown', "input[type='text'].effective_scale", (event) ->
  allowed = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '.']

  if event.key && event.key.length == 1 && event.metaKey == false && allowed.indexOf(event.key) == -1
    event.preventDefault()

# Assign the hidden input a value of ScaleX value
$(document).on 'change keyup', "input[type='text'].effective_scale", (event) ->
  $input = $(event.target)

  value = $input.val().replace(/,/g, '')
  scale = parseInt($input.data('scale'))

  unless value == ''
    value = (parseFloat(value || 0.0) * (10.0 ** scale)).toFixed(0)

  $input.siblings("input[type='hidden']").first().val(value)

# Format the value for display as currency (USD)
$(document).on 'change', "input[type='text'].effective_scale", (event) ->
  $input = $(event.target)

  value = $input.siblings("input[type='hidden']").first().val()
  scale = parseInt($input.data('scale'))

  unless value == ''
    value = parseInt(value || 0)

  if isNaN(value) == false && value != ''
    value = (value / (10.0 ** scale)) if value != 0

    value = value.toFixed(scale).toString()
    value = value.replace(('.' + '0'.repeat(scale)), '')
  else
    value = ''

  $input.val(value)
