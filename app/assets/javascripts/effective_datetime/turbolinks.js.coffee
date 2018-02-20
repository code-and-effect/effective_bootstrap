$(document).on 'turbolinks:before-cache', ->
  $('input.initialized.effective_date_time_picker').each (i, element) ->
    $input = $(element)
    $input.datetimepicker('destroy') if $input.data('datetimepicker')
    $input.removeClass('initialized')
