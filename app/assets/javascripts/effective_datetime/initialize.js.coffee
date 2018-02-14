# http://eonasdan.github.io/bootstrap-datetimepicker/Options/
(this.EffectiveBootstrap || {}).effective_datetime = ($element, options) ->
  $element.datetimepicker(options)
  $element.trigger('dp.end_date_initialized') if ($element.attr('name') || '').indexOf('[end_') != -1
