$(document).on 'direct-upload:initialize', (event) ->
  $target = $(event.target)
  template = $target.data('progress-template').replace('$ID$', event.detail.id).replace('$FILENAME$', event.detail.file.name)
  $target.closest('.effective-file-drop-zone').siblings('.uploads').append(template)

$(document).on 'direct-upload:start', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").removeClass('direct-upload--pending')

$(document).on 'direct-upload:progress', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").children('.direct-upload__progress').css('width', "#{event.detail.progress}%")

$(document).on 'direct-upload:error', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").addClass('direct-upload--error').attr('title', event.detail.error)

$(document).on 'direct-upload:end', (event) ->
  $obj = $("[data-direct-upload-id=#{event.detail.id}]")

  $obj.addClass('direct-upload--complete')

  # Rails UJS fix
  $obj.closest('form').find('[type=submit][data-confirm]').data('confirmed', true)

  # Disabled, to rule out trouble
  # Remove any empty [] inputs after upload
  # $obj.closest('.form-group').find('input').each (i, input) ->
  #   $input = $(input)
  #   $input.remove() unless $input.val()

$(document).on 'change', "input[type='file'][data-click-submit]", (event) ->
  $(event.currentTarget).closest('form').find('button[type=submit],input[type=submit]').first().click()

# Drag-and-drop support for file inputs
$(document).on 'dragover', '.effective-file-drop-zone', (event) ->
  event.preventDefault()
  event.originalEvent.dataTransfer.dropEffect = 'copy'

$(document).on 'dragenter', '.effective-file-drop-zone', (event) ->
  event.preventDefault()
  $zone = $(event.currentTarget)
  count = ($zone.data('drag-count') || 0) + 1
  $zone.data('drag-count', count)
  $zone.addClass('drag-over')

$(document).on 'dragleave', '.effective-file-drop-zone', (event) ->
  event.preventDefault()
  $zone = $(event.currentTarget)
  count = ($zone.data('drag-count') || 0) - 1
  $zone.data('drag-count', count)
  $zone.removeClass('drag-over') if count <= 0

$(document).on 'drop', '.effective-file-drop-zone', (event) ->
  event.preventDefault()
  $zone = $(event.currentTarget)
  $zone.removeClass('drag-over').data('drag-count', 0)

  $input = $zone.find('input[type=file]')
  return if $input.prop('disabled') || $input.prop('readonly')

  files = event.originalEvent.dataTransfer.files
  return unless files.length > 0

  if $input.prop('multiple')
    $input[0].files = files
  else
    dt = new DataTransfer()
    dt.items.add(files[0])
    $input[0].files = dt.files

  $input.trigger('change')

# Per-file Remove / Undo toggle on existing attachments
$(document).on 'click', '.effective-file-remove', (event) ->
  event.preventDefault()
  $button = $(event.currentTarget)
  $attachment = $button.closest('.effective-file-attachment')
  $input = $attachment.find('.effective-file-remove-input')

  if $input.prop('disabled')
    $input.prop('disabled', false)
    $attachment.addClass('effective-file-attachment--pending-removal')
    $button.text('Undo').removeClass('btn-outline-danger').addClass('btn-outline-secondary')
  else
    $input.prop('disabled', true)
    $attachment.removeClass('effective-file-attachment--pending-removal')
    $button.text('Remove').removeClass('btn-outline-secondary').addClass('btn-outline-danger')
