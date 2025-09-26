initialize = ->
  $buttons = $('.btn-clipboard-copy:not(.initialized)')
  return if $buttons.length == 0

  clipboard = new ClipboardJS('.btn-clipboard-copy',
    text: (trigger) -> $(trigger).data('clipboard')
  )

  clipboard.on 'success', (event) ->
    $obj = $(event.trigger).text('Copied!').focus().blur()
    setTimeout((-> $obj.html($obj.data('clipboard-label'))), 1500)

  $buttons.on 'click', (event) -> event.preventDefault()

  $buttons.addClass('initialized')

$ -> initialize()
$(document).on 'turbolinks:load', -> initialize()
