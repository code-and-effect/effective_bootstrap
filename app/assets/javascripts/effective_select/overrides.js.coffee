# Keep the order of selected tags
# Fixes https://github.com/select2/select2/issues/3106
$(document).on 'select2:select', 'select', (event) ->
  $el = $(event.params.data.element)
  $(this).append($el.detach()).trigger('change') if $el.closest('select').hasClass('tags-input')
  true

# Disable dropdown opening when clicking the clear button
# http://stackoverflow.com/questions/29618382/disable-dropdown-opening-on-select2-clear
$(document).on 'select2:unselecting', (event) -> $(event.target).data('state', 'unselected')

$(document).on 'select2:open', (event) ->
  $select = $(event.target)

  if $select.data('state') == 'unselected'
    $select.removeData('state')
    setTimeout ( => $select.select2('close') ), 0

# For tabbing through
# https://stackoverflow.com/questions/20989458/select2-open-dropdown-on-focus
$(document).on 'focus', '.select2-selection.select2-selection--single', (event) ->
  $(event.currentTarget).closest('.select2-container').siblings('select:enabled').select2('open');

$(document).on 'select2:closing', (event) ->
  $(event.target).data('select2').$selection.one('focus focusin', (event) -> event.stopPropagation())

$(document).on 'keydown', '.select2-container', (event) ->
  console.log $(event.target)
  console.log $(event.currentTarget)

  #return unless event.keyCode == 9

  id = $(event.target).closest('.select2-container').find('.select2-results').children('ul').attr('id')
  return unless id.length > 0 # select2-charge_accounting_code_id-results

  $select = $("select##{id.substring(8, id.length - 8)}")
  return unless $select.length > 0

  $option = $select.data('select2').$dropdown.find('.select2-results__option--highlighted')
  return unless $option.length > 0

  id = $option.attr('id')
  return unless id.length > 0

  value = id.substring(id.lastIndexOf('-') + 1)

  $select.val(value).trigger('change')

# effective_select custom reinitialization functionality
# This is a custom event intended to be manually triggered when the underlying options change
# You can use this to dynamically disable options (with or without the effective_select hide_disabled: true)
# https://github.com/select2/select2/issues/2830

# To trigger this event,
# $(document).on 'change', "select[name$='[something_id]']", (event) ->
#   ...add/remove/disable this select field's options...
#   $(event.target).select2().trigger('select2:reinitialize')

$(document).on 'select2:reinitialize', (event) ->
  $select = $(event.target)

  # Get the existing options and value
  options = $select.data('select2').options.options['inputJsOptions'] || {}
  value = $select.find('option:selected').val()

  # Clear/Restore the value appropriately
  if value && $select.find("option:enabled[value='#{value}']").length > 0
    $select.val(value)
  else
    $select.val('')

  # Reinitialize select2
  $select.select2('destroy').select2(options)

  # Restore effective_select custom class functionality
  $select.data('select2').$container.addClass(options['containerClass']) if options['containerClass']
  $select.data('select2').$dropdown.addClass(options['dropdownClass']) if options['dropdownClass']

  $select.trigger('change')
  true


