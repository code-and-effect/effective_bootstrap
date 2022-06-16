# Fade out cocoon remove.
$(document).on 'cocoon:before-remove', (event, $obj) ->
  $button = $(event.currentTarget.activeElement)

  confirm = ($button.data('confirm') || '').length > 0
  confirmed = $button.data('confirmed') || false

  if confirm && !confirmed
    event.preventDefault()
  else if $button.data('skip-fadeout')
    # Nothing to do
  else
    $(event.target).data('remove-timeout', 1000)
    $obj.fadeOut('slow')

# Open all external trix links in a new window.
$(document).on 'click', '.trix-content a', (event) ->
  obj = event.currentTarget

  if obj.host != window.location.host && !obj.isContentEditable
    obj.setAttribute('target', '_blank')
