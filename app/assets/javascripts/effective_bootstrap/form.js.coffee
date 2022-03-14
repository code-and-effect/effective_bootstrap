this.EffectiveForm ||= new class
  current_submit: ''                  # The $(.form-actions) that clicked
  current_delete: ''                  # If there's a rails ujs_delete link with the data-closeset selector, use this.
  remote_form_commit: ''              # String containing the last params[:commit]
  remote_form_payload: ''             # String containing html from server side render of this form
  remote_form_flash: ''               # Array of Arrays
  remote_form_redirect: ''            # String containing the redirect path (optional)

  validate: (form) ->
    valid = form.checkValidity()
    $form = $(form)

    @clearFlash()
    @reset($form) if $form.hasClass('was-validated')

    if valid then @submitting($form) else @invalidate($form)
    valid

  submitting: ($form) ->
    $form.addClass('form-is-valid').removeClass('form-is-invalid')
    @spin()
    setTimeout((-> EffectiveForm.disable($form)), 0)

    if ($form.attr('method') || '').toLowerCase() == 'get' || (@current_submit.length > 0 && @current_submit.hasClass('form-actions-reset'))
      setTimeout((-> EffectiveForm.reset($form)), 2500)

  invalidate: ($form) ->
    $form.addClass('was-validated').addClass('form-is-invalid')
    $form.find('.form-current-submit').removeClass('form-current-submit')

    # These controls need a little bit of help with client side validations
    $form.find('.effective-radios:not(.no-feedback),.effective-checks:not(.no-feedback)').each ->
      $(@).addClass(if $(@).find('input:invalid').length > 0 then 'is-invalid' else 'is-valid')

    @flash($form, 'danger')

  disable: ($form) ->
    $form.find('[type=submit]').prop('disabled', true)

  reset: ($form) ->
    $form = $form.closest('form') unless $form.is('form')

    $form.removeClass('was-validated').removeClass('form-is-invalid').removeClass('form-is-valid')
    $form.find('.form-current-submit').removeClass('form-current-submit')

    # Clear any server side validation on individual inputs
    $form.find('.alert.is-invalid').remove()
    $form.find('.is-invalid').removeClass('is-invalid')
    $form.find('.is-valid').removeClass('is-valid')

    $form.find('[type=submit]').removeAttr('disabled')
    $form

  clear: ($form) ->
    $form.find('input').not(':button, :submit, :reset, :hidden, :checkbox, :radio').val('')
    $form.find('textarea').val('')
    $form.find('select').val('').trigger('change.select2')
    $form.find('input[type=checkbox],input[type=radio]').prop('checked', false).trigger('change')

  spin: -> @current_submit.addClass('form-current-submit') if @current_submit.length > 0

  beforeAjax: ($form) ->
    return unless $form.data('remote')

    $form.one 'ajax:success', (event, data, status) ->
      EffectiveForm.loadFromAjax($(event.target), $(event.target).data('method') == 'delete')

    $form.one 'ajax:error', (event, _, status, message) ->
      EffectiveForm.reset($(event.target))
      EffectiveForm.flash($(event.target), 'danger', "#{status}: #{message || 'unable to contact server. please refresh the page and try again.'}")

  # Loads remote for payload that was placed here by effective_resources create.js.erb and update.js.erb
  loadFromAjax: ($target, was_delete) ->
    $target = $target.closest('form') unless $target.is('form')
    $form = ''

    if @remote_form_redirect.length > 0
      window.location.href = @remote_form_redirect
      @remote_form_redirect = ''
      return

    if @remote_form_payload.length > 0
      $payload = $("<div>#{@remote_form_payload}</div>")
      $form = $payload.find("form[data-remote-index='#{$target.data('remote-index')}']")
      $form = $payload.find('form').first() if $form.length == 0
      $form.attr('data-remote', true)
      @remote_form_payload = ''

    # There's nothing to update if it was a successful delete
    return if was_delete

    # Process remote form
    if $form.length > 0
      EffectiveBootstrap.initialize($form)
      $target.replaceWith($form)
    else
      $form = @reset($target) # There is no remote form. So we assume success and reset the submitted one.

    if @current_submit.length > 0
      @current_submit = $form.find("##{@current_submit.attr('id')}.form-actions")

    # Process Flash
    flash_status = 'success'
    flash_message = ''

    if @remote_form_flash.length > 0
      flash_status = @remote_form_flash[0][0]
      flash_message = @remote_form_flash[0][1]

    @flash($form, flash_status, flash_message)

    # Fire off form events
    was_error = ($form.hasClass('with-errors') || flash_status == 'danger' || flash_status == 'error')

    if was_error
      $form.trigger('effective-form:error', [flash_message, @remote_form_commit])
    else
      $form.trigger('effective-form:success', [flash_message, @remote_form_commit])

    $form.trigger('effective-form:complete', @remote_form_commit, [flash_message, @remote_form_commit, was_error])

    @remote_form_flash = ''
    @remote_form_commit = ''
    @current_submit = ''
    true

  flash: ($form, status, message) ->
    return unless @current_submit.length > 0

    if status == 'danger' || status == 'error'
      @current_submit.find('.eb-icon-x').show().delay(1000).fadeOut('slow', -> $form.trigger('effective-form:error-animation-done', @remote_form_commit, message))
    else
      @current_submit.find('.eb-icon-check').show().delay(1000).fadeOut('slow', -> $form.trigger('effective-form:success-animation-done', @remote_form_commit, message))

    if (message || '').length > 0
      @current_submit.prepend(@buildFlash(status, message))

  clearFlash: -> @current_submit.find('.alert').remove() if @current_submit.length > 0

  buildFlash: (status, message) ->
    $("
      <div class='effective-form-flash alert alert-dismissable alert-#{status} fade show' role='alert'>
        #{message}
        <button class='btn-close' type='button' aria-label='Close' data-bs-dismiss='alert'>
        </button>
      </div>
    ")

  setCurrentSubmit: ($submit) ->
    if $submit.is('.form-actions')
      @current_submit = $submit
    else
      @current_submit = ''

  setCurrentDelete: ($delete) -> @current_delete = $delete

  clearCurrentSubmit: -> @current_submit = ''

  finishDelete: ->
    if @current_delete.length > 0
      @current_delete.fadeOut('slow', -> $(this).remove())
      @current_delete = ''

# Sets EffectiveBootstrap. current_click.
# This displays the spinner here, and directs any flash messages before and after loadRemoteForm
$(document).on 'click', '.form-actions a[data-remote],.form-actions button[type=submit]', (event) ->
  EffectiveForm.setCurrentSubmit($(@).parent())
  EffectiveForm.spin() unless $(@).attr('data-confirm')

# This actually attached the handlers to a remote ajax form when it or an action inside it triggers a remote thing.
$(document).on 'ajax:beforeSend', 'form[data-remote]', (event) ->
  EffectiveForm.beforeAjax($(@))
  this.checkValidity()

$(document).on 'ajax:beforeSend', '[data-method=delete]', (event) ->
  if ($delete = $(@)).data('closest')
    EffectiveForm.setCurrentDelete($delete.closest($delete.data('closest')))

# Clear
$(document).on 'reset', 'form', (event) ->
  $form = $(event.currentTarget)
  EffectiveForm.reset($form)

$(document).on 'clear', 'form', (event) ->
  $form = $(event.currentTarget)
  EffectiveForm.reset($form)
  setTimeout -> EffectiveForm.clear($form)
