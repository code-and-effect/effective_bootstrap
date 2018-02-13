(this.EffectiveBootstrap || {}).effective_phone = ($element, options) ->
  mask = options['mask']
  delete options['mask']
  $element.mask(mask, options)
