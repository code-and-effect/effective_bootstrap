elementSelector = 'input,textarea,select,button,div.form-has-many'

# When showing a parent block that contains nested show_if (e.g. scored card contains category
# blocks), trigger change on the inputs those nested blocks depend on so they run and only
# the visible nested block's same-named controls stay enabled (fixes blank operation on first submit).
triggerNestedLogic = ($element, $container) ->
  $element.find('.effective-form-logic').not($element).each (i, el) ->
    name = $(el).data('input-js-options').name
    $container.find('input, select').filter(-> $(this).attr('name') == name).first().trigger('change')

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
      matches = matches || ($target.is(':checked') && "#{options.value}" == 'true')
      matches = matches || (!$target.is(':checked') && ("#{options.value}" == 'false' || "#{options.value}" == ''))

    if matches
      $element.hide()
      $element.find(elementSelector).prop('disabled', true)
    else
      $element.fadeIn()
      $element.find(elementSelector).removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()

  # Maybe disable it now
  if options.needDisable
    $element.find(elementSelector).prop('disabled', true)

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
      $element.find(elementSelector).removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()
      triggerNestedLogic($element, $container)
    else
      $element.hide()
      $element.find(elementSelector).prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find(elementSelector).prop('disabled', true)

(this.EffectiveBootstrap || {}).effective_show_if_any = ($element, options) ->
  if options.nested
    $container = $element.parent('div.effective-form-logic') || $element.closest('form,div.effective-datatables-filters')
  else
    $container = $element.closest('form,div.effective-datatables-filters')

  $affects = $container.find("input[name='#{options.name}'],select[name='#{options.name}'],input[name='#{options.name}[]']")

  values = JSON.parse(options.value)

  $affects.on 'change dp.change', (event) ->
    selected = $(event.target).val()
    found = values.find((value) => (value == selected || "#{value}" == "#{selected}"))

    if found
      $element.fadeIn()
      $element.find(elementSelector).removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()
      triggerNestedLogic($element, $container)

    else
      $element.hide()
      $element.find(elementSelector).prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find(elementSelector).prop('disabled', true)
