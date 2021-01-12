(this.EffectiveBootstrap || {}).effective_has_many = ($element, options) ->
  if options.sortable
    $element.sortable(
      containerSelector: '.form-has-many',
      itemSelector: '.has-many-fields',
      handle: '.has-many-move'
      placeholder: "<div class='has-many-placeholder' />",
      onDrop: ($item, container, _super) ->
        $hasMany = $(container.target)
        $fields = $hasMany.children('.has-many-fields:not(.marked-for-destruction)')

        positions = $fields.find("input[name$='[position]']").map(-> this.value).get()

        if positions.length > 0
          index = Math.min.apply(Math, positions) || 0

          $fields.each((_, obj) ->
            $(obj).find("input[name$='[position]']").first().val(index)
            index = index + 1
          )

        _super($item, container)
    )

$(document).on 'click', '[data-effective-form-has-many-add]', (event) ->
  event.preventDefault()

  $obj = $(event.currentTarget)
  return unless $obj.closest('.form-has-many').length > 0

  uid = (new Date).valueOf()
  template = $obj.data('effective-form-has-many-template').replace(/HASMANYINDEX/g, uid)

  $template = $(template).hide().fadeIn('slow')
  EffectiveBootstrap.initialize($template)

  $obj.closest('.has-many-links').before($template)
  false

$(document).on 'click', '[data-effective-form-has-many-remove]', (event) ->
  event.preventDefault()

  $target = $(event.currentTarget)
  $input = $target.siblings("input[name$='[_destroy]']").first()
  $fields = $target.closest('.has-many-fields').first()

  if $input.length > 0
    $input.val('true')
    $fields.addClass('marked-for-destruction').fadeOut('slow')
  else
    $fields.fadeOut('slow', -> this.remove())

  false
