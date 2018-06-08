# https://quilljs.com/docs/download/
# https://github.com/quilljs/quill
(this.EffectiveBootstrap || {}).effective_editor = ($element, options) ->
  $input = $element.siblings('input').first()

  quill = new Quill('#' + $element.attr('id'), options)
  quill.setContents(JSON.parse($input.val()))

  quill.on 'text-change', (delta, old, source) ->
    value = quill.getContents()
    value['html'] = $element.children('.ql-editor').html()
    $input.val(JSON.stringify(value))
