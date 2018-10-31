# Prevent non-currency buttons from being pressed
$(document).on 'keydown', "input[type='text'].effective_percent", (event) ->
  allowed = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '.']

  if event.key && event.key.length == 1 && event.metaKey == false && allowed.indexOf(event.key) == -1
    event.preventDefault()

# Assign the hidden input a value of 100x value
$(document).on 'change keyup', "input[type='text'].effective_percent", (event) ->
  $input = $(event.target)
  value = $input.val()

  unless value == ''
    value = (parseFloat(value || 0.00) * 1000.00).toFixed(0)

  $input.siblings("input[type='hidden']").first().val(value)

# Format the value for display as percentage
$(document).on 'change', "input[type='text'].effective_percent", (event) ->
  $input = $(event.target)
  value = $input.siblings("input[type='hidden']").first().val()
  max = 100000 # 100% is our max value

  unless value == ''
    value = parseInt(value || 0)

    if value > max # 100% is our max value
      value = max
      $input.siblings("input[type='hidden']").first().val(max)

    if value < -max # -100% is our min value
      value = -max
      $input.siblings("input[type='hidden']").first().val(-max)

    value = (value / 1000.0) if value != 0
    value = value.toFixed(3).toString()
    value = value.replace('.000', '') if value.endsWith('.000')

  $input.val(value)
