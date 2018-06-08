# https://quilljs.com/docs/download/
# https://github.com/quilljs/quill
(this.EffectiveBootstrap || {}).effective_editor = ($element, options) ->
  editor = '#' + $element.attr('id') + '_editor'

  quill = new Quill(editor, options)
  quill.pasteHTML($element.val())

  quill.on 'text-change', (delta, old, source) ->
    html = $(editor).children('.ql-editor').html()
    html = '' if html == '<p><br></p>' || html == '<p></p>'
    $element.val(html)
