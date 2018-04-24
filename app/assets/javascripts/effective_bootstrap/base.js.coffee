this.EffectiveBootstrap ||= new class
  current_submit: ''              # The $(.form-actions) that clicked
  remote_form_payload: ''         # A fresh form
  remote_form_flash: ''           # Array of Arrays

  initialize: (target) ->
    $(target || document).find('[data-input-js-options]:not(.initialized)').each (i, element) ->
      $element = $(element)
      options = $element.data('input-js-options')

      method_name = options['method_name']
      delete options['method_name']

      unless EffectiveBootstrap[method_name]
        return console.error("EffectiveBootstrap #{method_name} has not been implemented")

      EffectiveBootstrap[method_name].call(this, $element, options)
      $element.addClass('initialized')

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
    setTimeout((-> EffectiveBootstrap.disable($form)), 0)

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
    $form.removeClass('was-validated').removeClass('form-is-invalid').removeClass('form-is-valid')
    $form.find('.form-current-submit').removeClass('form-current-submit')

    # Clear any server side validation on individual inputs
    $form.find('.alert.is-invalid').remove()
    $form.find('.is-invalid').removeClass('is-invalid')
    $form.find('.is-valid').removeClass('is-valid')

    $form.find('[type=submit]').removeAttr('disabled')

  spin: -> @current_submit.addClass('form-current-submit') if @current_submit.length > 0

  beforeAjax: ($form) ->
    return unless $form.data('remote')

    $form.one 'ajax:success', (event, thing, another) ->
      EffectiveBootstrap.loadFromAjax($(event.target), $(event.target).data('method') == 'delete')

    $form.one 'ajax:error', (event, _, status, message) ->
      EffectiveBootstrap.reset($(event.target))
      EffectiveBootstrap.flash($(event.target), 'danger', "Ajax #{status}: #{message}")

  # Loads remote for payload that was placed here by effective_resources create.js.erb and update.js.erb
  loadFromAjax: ($target, was_delete) ->
    $target = $target.closest('form') unless $target.is('form')

    if @remote_form_payload.length > 0
      $form = @remote_form_payload.find("form[data-remote-index='#{$target.data('remote-index')}']")
      $form = @remote_form_payload.find('form') if $form.length == 0
      if $form.length > 0
        @initialize($form)
        $target.replaceWith($form)

    # We update the current submit to point to the new one.
    unless was_delete
      if @current_submit.length > 0
        @current_submit = $form.find("##{@current_submit.attr('id')}.form-actions")

      if @remote_form_flash.length > 0 && was_delete == false
        for flash in @remote_form_flash
          @flash($form, flash[0], flash[1], true)

    @remote_form_payload = ''; @remote_form_flash = ''; @current_submit = '';

  flash: ($form, status, message, skip_success = false) ->
    if status == 'danger' || status == 'error'
      @current_submit.find('.eb-icon-x').show().delay(1000).fadeOut('slow')
    else
      @current_submit.find('.eb-icon-check').show().delay(1000).fadeOut('slow')

    if message? && !(status == 'success' && skip_success)
      @current_submit.prepend(@buildFlash(status, message))

  clearFlash: -> @current_submit.find('.alert').remove() if @current_submit.length > 0

  buildFlash: (status, message) ->
    $("
      <div class='alert alert-dismissable alert-#{status} fade show' role='alert'>
        #{message}
        <button class='close' type='button' aria-label='Close' data-dismiss='alert'>
          <span aria-hidden='true'>&times;</span>
        </button>
      </div>
    ")

  setCurrentSubmit: ($submit) -> @current_submit = $submit if $submit.is('.form-actions')

$ -> EffectiveBootstrap.initialize()
$(document).on 'turbolinks:load', -> EffectiveBootstrap.initialize()
$(document).on 'cocoon:after-insert', -> EffectiveBootstrap.initialize()
$(document).on 'effective-bootstrap:initialize', (event) -> EffectiveBootstrap.initialize(event.currentTarget)

# Sets EffectiveBootstrap. current_click.
# This displays the spinner here, and directs any flash messages before and after loadRemoteForm
$(document).on 'click', '.form-actions a[data-remote],.form-actions button[type=submit]', (event) ->
  EffectiveBootstrap.setCurrentSubmit($(@).parent())
  EffectiveBootstrap.spin()

# This actually attached the handlers to a remote ajax form when it or an action inside it triggers a remote thing.
$(document).on 'ajax:beforeSend', 'form[data-remote]', (event) ->
  EffectiveBootstrap.beforeAjax($(@))
  this.checkValidity()

# These next two three methods hijack jquery_ujs data-confirm and do it our own way with a double click confirm
$(document).on 'confirm', (event) ->
  $obj = $(event.target)

  if $obj.data('confirmed')
    true
  else
    $obj.data('confirm-original', $obj.html())
    $obj.html($obj.data('confirm'))
    $obj.data('confirmed', true)
    setTimeout(
      (->
        $obj.data('confirmed', false)
        $obj.html($obj.data('confirm-original'))
      )
      , 4000)
    false # don't show the confirmation dialog

$.rails.confirm = (message) -> true
$(document).on 'confirm:complete', (event) -> $(event.target).data('confirmed')
