$(document).on 'direct-upload:initialize', (event) ->
  $target = $(event.target)
  template = $target.data('progress-template').replace('$ID$', event.detail.id).replace('$FILENAME$', event.detail.file.name)
  $target.siblings('.uploads').append(template)

$(document).on 'direct-upload:start', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").removeClass('direct-upload--pending')

$(document).on 'direct-upload:progress', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").children('.direct-upload__progress').css('width', "#{event.detail.progress}%")

$(document).on 'direct-upload:error', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").addClass('direct-upload--error').attr('title', event.detail.error)

$(document).on 'direct-upload:end', (event) ->
  $("[data-direct-upload-id=#{event.detail.id}]").addClass('direct-upload--complete')

$(document).on 'change', "input[type='file'][data-click-submit]", (event) ->
  $(event.currentTarget).closest('form').find('button[type=submit],input[type=submit]').first().click()
