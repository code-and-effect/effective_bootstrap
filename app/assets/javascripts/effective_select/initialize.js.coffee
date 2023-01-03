# https://select2.github.io/examples.html

effectiveFormat = (data, container) ->
  if data.element && data.element.getAttribute('data-html')
    $(data.element.getAttribute('data-html'))
  else if data.text.startsWith("<") && data.text.endsWith(">")
    $(data.text)
  else
    data.text

effectiveMatch = (params, data) ->
  return data if $.trim(params.term) == ''
  return null unless data.element?

  # Single item mode
  term = params.term.toLowerCase()

  # The text value
  text = ''
  try text = $(data.element.getAttribute('data-html')).text()
  try text = $(data.text).text() if text.length == 0
  text = data.text if text.length == 0

  return(data) if text.length > 0 && text.toLowerCase().indexOf(term) > -1
  return null unless data.children?

  # OptGroup mode
  filteredChildren = []

  $.each(data.children, (idx, child) ->
    # Text value
    text = ''
    try text = $(child.element.getAttribute('data-html')).text()
    try text = $(child.text).text() if text.length == 0
    text = child.text if text.length == 0

    filteredChildren.push(child) if text.toLowerCase().indexOf(term) > -1
  )

  return null if filteredChildren.length == 0

  modifiedData = $.extend({}, data, true)
  modifiedData.children = filteredChildren

  return modifiedData

(this.EffectiveBootstrap || {}).effective_select = ($element, options) ->
  options['templateResult'] = effectiveFormat
  options['templateSelection'] = effectiveFormat
  options['matcher'] = effectiveMatch

  if options['noResults']
    noResults = options['noResults']
    delete options['noResults']
    options['language'] = { noResults: (_) -> noResults }

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
