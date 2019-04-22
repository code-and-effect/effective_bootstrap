# Fade out cocoon remove.
$(document).on 'cocoon:before-remove', (event, $obj) ->
  $(event.target).data('remove-timeout', 1000)
  $obj.fadeOut('slow')
