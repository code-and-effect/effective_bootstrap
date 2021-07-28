assignPositions = (target) ->
  $hasMany = $(target)
  return unless $hasMany.length > 0

  $fields = $hasMany.children('.has-many-fields:not(.marked-for-destruction)')
  positions = $fields.find("input[name$='[position]'][type=hidden]").map(-> this.value).get()

  if positions.length > 0
    index = Math.min.apply(Math, positions) || 0

    $fields.each((i, obj) ->
      $(obj).find("input[name$='[position]']").first().val(index)
      index = index + 1
    )

  true

(this.EffectiveBootstrap || {}).effective_has_many = ($element, options) ->
  if options.sortable
    # https://github.com/SortableJS/Sortable
    $element.sortable({
      animation: 150,
      draggable: '.has-many-fields',
      handle: '.has-many-move',
      onEnd: (event) => assignPositions(event.to)
    })

$(document).on 'click', '[data-effective-form-has-many-add]', (event) ->
  event.preventDefault()

  $obj = $(event.currentTarget)
  $hasMany = $obj.closest('.form-has-many')
  return unless $hasMany.length > 0

  uid = (new Date).valueOf()
  template = atob($obj.data('effective-form-has-many-template')).replace(/HASMANYINDEX/g, uid)

  $fields = $(template).hide().fadeIn('fast')
  EffectiveBootstrap.initialize($fields)
  $obj.closest('.has-many-links').before($fields)

  assignPositions($hasMany)
  true

$(document).on 'click', '[data-effective-form-has-many-insert]', (event) ->
  event.preventDefault()

  $obj = $(event.currentTarget)
  $hasMany = $obj.closest('.form-has-many')
  return unless $hasMany.length > 0

  $add = $hasMany.children('.has-many-links').find('[data-effective-form-has-many-template]')

  uid = (new Date).valueOf()
  template = atob($add.data('effective-form-has-many-template')).replace(/HASMANYINDEX/g, uid)

  $fields = $(template).hide().fadeIn('fast')
  EffectiveBootstrap.initialize($fields)
  $obj.closest('.has-many-fields').after($fields)

  assignPositions($hasMany)
  true


$(document).on 'click', '[data-effective-form-has-many-remove-disabled]', (event) ->
  event.preventDefault()

$(document).on 'click', '[data-effective-form-has-many-remove]', (event) ->
  event.preventDefault()

  $obj = $(event.currentTarget)
  return unless $obj.data('confirmed') if $obj.data('confirm')

  $hasMany = $obj.closest('.form-has-many')
  return unless $hasMany.length > 0

  $input = $obj.siblings("input[name$='[_destroy]']").first()
  $fields = $obj.closest('.has-many-fields').first()

  if $input.length > 0
    $input.val('true')
    $fields.addClass('marked-for-destruction').fadeOut('fast')
  else
    $fields.fadeOut('fast', -> this.remove())

  assignPositions($hasMany)
  true

$(document).on 'click', '[data-effective-form-has-many-reorder]', (event) ->
  event.preventDefault()

  $obj = $(event.currentTarget)
  $hasMany = $obj.closest('.form-has-many')
  return unless $hasMany.length > 0

  $fields = $hasMany.children('.has-many-fields:not(.marked-for-destruction)')
  return unless $fields.length > 1

  $hasMany.toggleClass('reordering')
  true
