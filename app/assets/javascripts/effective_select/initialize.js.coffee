# https://select2.github.io/examples.html

formatWithGlyphicon = (data, container) ->
  if data.element && data.element.className
    $("<span><i class='glyphicon #{data.element.className}'></i> #{data.text}</span>")
  else
    data.text

formatWithHtml = (data, container) ->
  if data.element && data.element.getAttribute('data-html')
    $(data.element.getAttribute('data-html'))
  else
    data.text

matchWithHtml = (params, data) ->
  return data if $.trim(params.term) == ''
  return null unless data.element?

  if $(data.element.getAttribute('data-html')).text().indexOf(params.term) > -1 then data else null

(this.EffectiveBootstrap || {}).effective_select = ($element, options) ->
  switch options['template']
    when 'glyphicon'
      options['templateResult'] = formatWithGlyphicon
      options['templateSelection'] = formatWithGlyphicon
    when 'html'
      options['templateResult'] = formatWithHtml
      options['templateSelection'] = formatWithHtml
      options['matcher'] = matchWithHtml

  $select = $element.select2(options)

  # effective_select custom class functionality
  # select2 doesn't provide an initializer to add css classes to its input, so we manually support this feature
  # js_options[:containerClass] and js_options[:dropdownClass]
  $select.data('select2').$container.addClass(options['containerClass']) if options['containerClass']
  $select.data('select2').$dropdown.addClass(options['dropdownClass']) if options['dropdownClass']

$(document).on 'turbolinks:before-cache', ->
  $('select.effective_select.initialized').each (i, element) ->
    $input = $(element)
    $input.select2('destroy') if $input.data('select2')
    $input.removeClass('initialized')

# If we're working with a polymorphic select, split out the ID and assign the hidden _type and _id fields
$(document).on 'change', "select.effective_select.polymorphic", (event) ->
  $select = $(event.target)
  value = $select.val() || ''

  $select.siblings("input[type='hidden'][name$='_type]']").val(value.split('_')[0] || '')
  $select.siblings("input[type='hidden'][name$='_id]']").val(value.split('_')[1] || '')

# Keep the order of selected tags
# Fixes https://github.com/select2/select2/issues/3106
$(document).on 'select2:select', 'select', (event) ->
  $el = $(event.params.data.element)

  if $el.closest('select').hasClass('tags-input')
    $(this).append($el.detach()).trigger('change')
  true

