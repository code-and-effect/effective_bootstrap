disableRemovedFields = ($fields) ->
  # Rails still needs the record ID and destruction flag to delete persisted rows.
  $fields.find('input,textarea,select,button').not("input[type=hidden][name$='[id]'],input[type=hidden][name$='[_destroy]']").prop('disabled', true)

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
  disableRemovedFields($element.find('.has-many-fields.marked-for-destruction'))

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
  $obj.closest('.has-many-links').before($fields)
  EffectiveBootstrap.initialize($fields)

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
  $obj.closest('.has-many-fields').before($fields)
  EffectiveBootstrap.initialize($fields)

  assignPositions($hasMany)
  true

$(document).on 'click', '[data-effective-form-has-many-remove-disabled]', (event) ->
  event.preventDefault()

$(document).on 'click confirm:complete', '[data-effective-form-has-many-remove]', (event, answer) ->
  $obj = $(event.currentTarget)

  if event.type == 'click'
    event.preventDefault()
    # Let Rails finish confirmation before disabling the row, including this button.
    return if $obj.data('confirm') && (window.Rails || $.rails)
  else
    return unless answer || event.originalEvent?.detail?[0]

  $hasMany = $obj.closest('.form-has-many')
  return unless $hasMany.length > 0

  $input = $obj.siblings("input[name$='[_destroy]']").first()
  $fields = $obj.closest('.has-many-fields').first()

  disableRemovedFields($fields)

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
