(this.EffectiveBootstrap || {}).effective_hide_if = ($element, options) ->
  $affects = $element.closest('form,div.effective-datatables-filters').find("input[name='#{options.name}'],select[name='#{options.name}']")

  $affects.on 'change', (event) ->
    $target = $(event.target)
    matches = ($target.val() == options.value)

    if $target.is("[type='checkbox']")
      matches = matches || ($target.is(':checked') && "#{options.value}" == 'true')
      matches = matches || (!$target.is(':checked') && ("#{options.value}" == 'false' || "#{options.value}" == ''))

    if matches
      $element.hide()
      $element.find('input,textarea,select,button').prop('disabled', true)
    else
      $element.fadeIn()
      $element.find('input,textarea,select,button').removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()

  # Maybe disable it now
  if options.needDisable
    $element.find('input,textarea,select,button').prop('disabled', true)


(this.EffectiveBootstrap || {}).effective_show_if = ($element, options) ->
  $affects = $element.closest('form,div.effective-datatables-filters').find("input[name='#{options.name}'],select[name='#{options.name}']")

  $affects.on 'change', (event) ->
    $target = $(event.target)
    matches = ($target.val() == options.value)

    if $target.is("[type='checkbox']")
      matches = matches || ($target.is(':checked') && "#{options.value}" == 'true')
      matches = matches || (!$target.is(':checked') && ("#{options.value}" == 'false' || "#{options.value}" == ''))

    if matches
      $element.fadeIn()
      $element.find('input,textarea,select,button').removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()
    else
      $element.hide()
      $element.find('input,textarea,select,button').prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find('input,textarea,select,button').prop('disabled', true)

(this.EffectiveBootstrap || {}).effective_show_if_any = ($element, options) ->
  $affects = $element.closest('form,div.effective-datatables-filters').find("input[name='#{options.name}'],select[name='#{options.name}']")
  values = JSON.parse(options.value)

  $affects.on 'change', (event) ->
    selected = $(event.target).val()
    found = values.find((value) => (value == selected || "#{value}" == "#{selected}"))

    if found
      $element.fadeIn()
      $element.find('input,textarea,select,button').removeAttr('disabled')
      $element.find('textarea.effective_article_editor').each (i, editor) -> ArticleEditor('#' + $(editor).attr('id')).enable()

    else
      $element.hide()
      $element.find('input,textarea,select,button').prop('disabled', true)

  # Maybe disable it now
  if options.needDisable
    $element.find('input,textarea,select,button').prop('disabled', true)
