# http://eonasdan.github.io/bootstrap-datetimepicker/Options/
(this.EffectiveBootstrap || {}).effective_time = ($element, options) ->
  $element.datetimepicker(options)

  name = $element.attr('name') || ''
  if name.indexOf('end_') != -1 || name.indexOf('_end') != -1
    $element.trigger('dp.end_date_initialized')
