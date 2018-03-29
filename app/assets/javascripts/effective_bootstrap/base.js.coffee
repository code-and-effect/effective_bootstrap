this.EffectiveBootstrap ||= new class
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

    valid

  disable: ($form) ->
    $form.find('[type=submit]').prop('disabled', true)

  enable: ($form) ->
    $form.removeClass('form-is-valid').find('[type=submit]').removeAttr('disabled')

$ -> EffectiveBootstrap.initialize()
$(document).on 'turbolinks:load', -> EffectiveBootstrap.initialize()
$(document).on 'cocoon:after-insert', -> EffectiveBootstrap.initialize()
$(document).on 'effective-bootstrap:initialize', (event) -> EffectiveBootstrap.initialize(event.currentTarget)

$(document).on 'ajax:beforeSend', 'form[data-remote]', -> this.checkValidity()
