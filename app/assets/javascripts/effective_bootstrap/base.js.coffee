this.EffectiveBootstrap ||= new class
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
    $form = $(form)

    @reset($form)

    valid = form.checkValidity()

    if valid
      $form.addClass('form-is-valid')
      setTimeout((-> EffectiveBootstrap.disable($form)), 0)
    else
      $form.addClass('was-validated').addClass('form-is-invalid')

      $('.effective-radios,.effective-checks').each -> # These controls need a little bit of help with client side validations
        $(@).addClass(if $(@).find('input:invalid').length > 0 then 'is-invalid' else 'is-valid')

      @flash($form, 'danger')

    if valid and $form.data('remote')
      $form.one 'ajax:success', (event) -> EffectiveBootstrap.loadRemoteForm($(event.target))

      $form.one 'ajax:error', (event, _, status, message) ->
        EffectiveBootstrap.reset($(event.target))
        EffectiveBootstrap.flash($(event.target), 'danger', "Ajax #{status}: #{message}")

    valid

  submitting: ($form) ->
    $form.addClass('form-is-valid').removeClass('form-is-invalid')
    @disable($form)

  disable: ($form) ->
    $form.find('[type=submit]').prop('disabled', true)

  reset: ($form) ->
    $form.removeClass('was-validated').removeClass('form-is-invalid').removeClass('form-is-valid')

    # Clear any server side validation on individual inputs
    $form.find('.alert.is-invalid').remove()
    $form.find('.is-invalid').removeClass('is-invalid')
    $form.find('.is-valid').removeClass('is-valid')

    $form.find('[type=submit]').removeAttr('disabled')

  flash: ($form, status, message, skip_success = false) ->
    $actions = $form.children('.form-actions')

    if status == 'danger' || status == 'error'
      $actions.find('.eb-icon-x').show().delay(1000).fadeOut('slow')
    else
      $actions.find('.eb-icon-check').show().delay(1000).fadeOut('slow')

    if message? && !(status == 'success' && skip_success)
      $actions.prepend(@buildFlash(status, message))

  # Loads remote for payload that was placed here by effective_resources create.js.erb and update.js.erb
  loadRemoteForm: ($target) ->
    if @remote_form_payload?
      $form = @remote_form_payload.find("form[data-remote-index='#{$target.data('remote-index')}']")
      $form = @remote_form_payload.find('form') if $form.length == 0
      $target.replaceWith($form)

    if @remote_form_flash?
      for flash in @remote_form_flash
        @flash($form, flash[0], flash[1], true)

    @remote_form_payload = ''; @remote_form_flash = '';

  buildFlash: (status, message) ->
    $("
      <div class='alert alert-dismissable alert-#{status} fade show' role='alert'>
        #{message}
        <button class='close' type='button' aria-label='Close' data-dismiss='alert'>
          <span aria-hidden='true'>&times;</span>
        </button>
      </div>
    ")

$ -> EffectiveBootstrap.initialize()
$(document).on 'turbolinks:load', -> EffectiveBootstrap.initialize()
$(document).on 'cocoon:after-insert', -> EffectiveBootstrap.initialize()
$(document).on 'effective-bootstrap:initialize', (event) -> EffectiveBootstrap.initialize(event.currentTarget)

$(document).on 'ajax:beforeSend', 'form[data-remote]', -> this.checkValidity()
