(this.EffectiveBootstrap || {}).effective_hide_if = ($element, options) ->

  $affects = $element.closest('form').find("input[name='#{options.name}'],select[name='#{options.name}']")

  $affects.on 'change', (event) ->
    if $(event.target).val() == options.value
      $element.hide()
      element.find('input,textarea,select').prop('disabled', true)
    else
      $element.fadeIn()
      $element.find('input,textarea,select').removeAttr('disabled')

  # Maybe disable it now
  if options.needDisable
    $element.find('input,textarea,select').prop('disabled', true)


(this.EffectiveBootstrap || {}).effective_show_if = ($element, options) ->

  $affects = $element.closest('form').find("input[name='#{options.name}'],select[name='#{options.name}']")

  $affects.on 'change', (event) ->
    if $(event.target).val() == options.value
      $element.fadeIn()
      $element.find('input,textarea,select').removeAttr('disabled')
    else
      $element.hide()
      $element.find('input,textarea,select').prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find('input,textarea,select').prop('disabled', true)

