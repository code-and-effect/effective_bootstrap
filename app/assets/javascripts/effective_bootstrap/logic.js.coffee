(this.EffectiveBootstrap || {}).effective_hide_if = ($element, options) ->

  $affects = $element.closest('form').find("input[name='#{options.name}']")

  $affects.on 'change', (event) ->
    if $(event.target).val() == options.value
      $element.hide()
    else
      $element.fadeIn()

(this.EffectiveBootstrap || {}).effective_show_if = ($element, options) ->

  $affects = $element.closest('form').find("input[name='#{options.name}']")

  $affects.on 'change', (event) ->
    if $(event.target).val() == options.value
      $element.fadeIn()
    else
      $element.hide()

