this.EffectiveBootstrap ||= new class
  remote_form_payload: ''
  remote_form_flash: ''

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

    # Clear any server side validation on individual inputs
    $form.find('.alert.is-invalid').remove()
    $form.find('.is-invalid').removeClass('is-invalid')
    $form.find('.is-valid').removeClass('is-valid')

    valid = form.checkValidity()

    if valid
      $form.addClass('form-is-valid').removeClass('form-is-invalid')
      setTimeout((-> EffectiveBootstrap.disable($form)), 0)
    else
      $form.addClass('was-validated').addClass('form-is-invalid').removeClass('form-is-valid')

    if valid and $form.data('remote')
      $form.one 'ajax:success', (event) -> EffectiveBootstrap.loadRemoteForm($(event.target))

    valid

  submitting: ($form) ->
    $form.addClass('form-is-valid').removeClass('form-is-invalid')
    @disable($form)

  disable: ($form) ->
    $form.find('[type=submit]').prop('disabled', true)

  enable: ($form) ->
    $form.removeClass('form-is-valid').find('[type=submit]').removeAttr('disabled')

  # Loads remote for payload that was placed here by effective_resources create.js.erb and update.js.erb
  loadRemoteForm: ($form) ->
    $newForm = @remote_form_payload.find('form')

    for flash in @remote_form_flash
      status = flash[0]
      message = flash[1]
      $newForm.prepend($("<div class='alert alert-#{status}'>#{message}</div>"))

    $form.replaceWith($newForm)
    @remote_form_payload = ''; @remote_form_flash = ''


$ -> EffectiveBootstrap.initialize()
$(document).on 'turbolinks:load', -> EffectiveBootstrap.initialize()
$(document).on 'cocoon:after-insert', -> EffectiveBootstrap.initialize()
$(document).on 'effective-bootstrap:initialize', (event) -> EffectiveBootstrap.initialize(event.currentTarget)

$(document).on 'ajax:beforeSend', 'form[data-remote]', -> this.checkValidity()
