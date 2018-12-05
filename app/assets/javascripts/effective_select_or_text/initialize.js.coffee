$(document).on 'click', '[data-effective-select-or-text]', (event) ->
  $obj = $(event.currentTarget).closest('.effective-select-or-text')

  $visible = $obj.children('.form-group:visible').first()
  $hidden = $obj.children('.form-group:not(:visible)').first()

  $visible.fadeOut('fast', ->
    $visible.find('select').val('').trigger('change.select2')
    $visible.find('input').val('')

    $hidden.slideDown('fast')
  )

  false

