elementSelector = 'input,textarea,select,button,div.form-has-many'

# When multiple show_if blocks contain radio buttons with the same name, the browser only keeps the last one checked. 
# If that radio is in a # hidden/disabled block, the visible block's radio won't be checked.
# This syncs the checked state from disabled radios to their enabled counterparts.
syncDisabledRadioButtons = ($container) ->
  $container.find('input[type="radio"]:checked:disabled').each ->
    name = $(this).attr('name')
    value = $(this).val()
    $container.find("input[type='radio'][name='#{name}'][value='#{value}']:enabled").prop('checked', true)

(this.EffectiveBootstrap || {}).effective_hide_if = ($element, options) ->
  if options.nested
    $container = $element.parent('div.effective-form-logic') || $element.closest('form,div.effective-datatables-filters')
  else
    $container = $element.closest('form,div.effective-datatables-filters')

  $affects = $container.find("input[name='#{options.name}'],select[name='#{options.name}'],input[name='#{options.name}[]']")

  $affects.on 'change dp.change', (event) ->
    $target = $(event.target)
    matches = ($target.val() == options.value)

    if $target.is("[type='checkbox']")
      if $target.attr('name').indexOf('[]') == -1
        matches = matches || ($target.is(':checked') && "#{options.value}" == 'true')
        matches = matches || (!$target.is(':checked') && ("#{options.value}" == 'false' || "#{options.value}" == ''))
      else
        selected = $target.closest('fieldset').find("[name='#{options.name}[]']:checked").map((i, el) -> $(el).val()).get()
        matches = selected.find((value) => (value == options.value || "#{value}" == "#{options.value}"))

    if matches
      $element.hide()
      $element.find(elementSelector).prop('disabled', true)
    else
      $element.fadeIn()
      $element.find(elementSelector).not($element.find('.effective-form-logic:hidden').find(elementSelector)).removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()

  # Maybe disable it now
  if options.needDisable
    $element.find(elementSelector).prop('disabled', true)
    syncDisabledRadioButtons($container)

(this.EffectiveBootstrap || {}).effective_show_if = ($element, options) ->
  if options.nested
    $container = $element.parent('div.effective-form-logic') || $element.closest('form,div.effective-datatables-filters')
  else
    $container = $element.closest('form,div.effective-datatables-filters')

  $affects = $container.find("input[name='#{options.name}'],select[name='#{options.name}'],input[name='#{options.name}[]']")

  $affects.on 'change dp.change', (event) ->
    $target = $(event.target)
    matches = ($target.val() == options.value)

    if $target.is("[type='checkbox']")
      if $target.attr('name').indexOf('[]') == -1
        matches = matches || ($target.is(':checked') && "#{options.value}" == 'true')
        matches = matches || (!$target.is(':checked') && ("#{options.value}" == 'false' || "#{options.value}" == ''))
      else
        selected = $target.closest('fieldset').find("[name='#{options.name}[]']:checked").map((i, el) -> $(el).val()).get()
        matches = selected.find((value) => (value == options.value || "#{value}" == "#{options.value}"))

    if matches
      $element.fadeIn()
      $element.find(elementSelector).not($element.find('.effective-form-logic:hidden').find(elementSelector)).removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()
    else
      $element.hide()
      $element.find(elementSelector).prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find(elementSelector).prop('disabled', true)
    syncDisabledRadioButtons($container)

(this.EffectiveBootstrap || {}).effective_show_if_any = ($element, options) ->
  if options.nested
    $container = $element.parent('div.effective-form-logic') || $element.closest('form,div.effective-datatables-filters')
  else
    $container = $element.closest('form,div.effective-datatables-filters')

  $affects = $container.find("input[name='#{options.name}'],select[name='#{options.name}'],input[name='#{options.name}[]']")

  values = JSON.parse(options.value)

  $affects.on 'change dp.change', (event) ->
    $target = $(event.target)
    selected = $target.val()
    found = values.find((value) => (value == selected || "#{value}" == "#{selected}"))

    if $target.is("[type='checkbox']")
      if $target.attr('name').indexOf('[]') == -1
        found = found || ($target.is(':checked') && values.find((value) => "#{value}" == 'true'))
        found = found || (!$target.is(':checked') && values.find((value) => ("#{value}" == 'false' || "#{value}" == '')))
      else
        checked = $target.closest('fieldset').find("[name='#{options.name}[]']:checked").map((i, el) -> $(el).val()).get()
        found = values.find((value) => checked.find((sel) => (sel == value || "#{sel}" == "#{value}")))

    if found
      $element.fadeIn()
      $element.find(elementSelector).not($element.find('.effective-form-logic:hidden').find(elementSelector)).removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()

    else
      $element.hide()
      $element.find(elementSelector).prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find(elementSelector).prop('disabled', true)
    syncDisabledRadioButtons($container)
