(this.EffectiveBootstrap || {}).effective_time_zone_select = ($element, options) ->
  unless $element.val().length > 0
    try
      offset = moment().format('Z')

      zones = $element.find('option').filter -> $(this).text().includes(offset)
      zone = zones.find (obj) -> $(obj).text().includes('Time') # Favor Mountain Time (US & Canada) over Arizona

      guess = if zone.length > 0 then zone else zones.first()

      $element.val(guess.val()) if guess.length > 0

  $select = $element.select2(options)
