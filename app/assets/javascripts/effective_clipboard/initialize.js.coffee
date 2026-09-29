clipboard = null

destroy = ->
  clipboard?.destroy()
  clipboard = null
  $('.btn-clipboard-copy.initialized').off('click.effective-clipboard').removeClass('initialized').each ->
    $(@).html($(@).data('clipboard-label'))

initialize = ->
  destroy()
  $buttons = $('.btn-clipboard-copy:not(.initialized)')
  return if $buttons.length == 0

  clipboard = new ClipboardJS('.btn-clipboard-copy',
    text: (trigger) -> $(trigger).data('clipboard')
  )

  clipboard.on 'success', (event) ->
    $obj = $(event.trigger).text('Copied!').focus().blur()
    setTimeout((-> $obj.html($obj.data('clipboard-label'))), 1500)

  $buttons.on 'click.effective-clipboard', (event) -> event.preventDefault()

  $buttons.addClass('initialized')

$ -> initialize()
$(document).on 'turbolinks:load turbo:load', -> initialize()
$(document).on 'turbolinks:before-cache turbo:before-cache', -> destroy()
