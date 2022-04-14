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

  # Single item mode
  term = params.term.toLowerCase()
  text = $(data.element.getAttribute('data-html')).text()

  if(text.length > 0)
    if text.toLowerCase().indexOf(term) > -1 then return(data) else return(null)

  return null unless data.children?

  # OptGroup mode
  filteredChildren = []

  $.each(data.children, (idx, child) ->
    text = $(child.element.getAttribute('data-html')).text()
    filteredChildren.push(child) if text.toLowerCase().indexOf(term) > -1
  )

  return null if filteredChildren.length == 0

  modifiedData = $.extend({}, data, true)
  modifiedData.children = filteredChildren

  return modifiedData

(this.EffectiveBootstrap || {}).effective_select = ($element, options) ->
  switch options['template']
    when 'glyphicon'
      options['templateResult'] = formatWithGlyphicon
      options['templateSelection'] = formatWithGlyphicon
    when 'html'
      options['templateResult'] = formatWithHtml
      options['templateSelection'] = formatWithHtml
      options['matcher'] = matchWithHtml

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
