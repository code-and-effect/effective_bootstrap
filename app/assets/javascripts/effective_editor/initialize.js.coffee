# https://quilljs.com/docs/download/
# https://github.com/quilljs/quill
(this.EffectiveBootstrap || {}).effective_editor = ($element, options) ->
  editor = '#' + $element.attr('id') + '_editor'

  delta = options['delta']
  delete options['delta']

  quill = new Quill(editor, options)
  content = $element.val() || ''

  if content.length > 0
    if content.startsWith('{') then quill.setContents(JSON.parse(content)) else quill.pasteHTML(content)

  if delta
    quill.on 'text-change', (delta, old, source) ->
      $element.val(JSON.stringify(quill.getContents()))
  else
    quill.on 'text-change', (delta, old, source) ->
      html = $(editor).children('.ql-editor').html()
      html = '' if html == '<p><br></p>' || html == '<p></p>'
      $element.val(html)

  $element.on 'quill:focus', (event) -> quill.focus()

# This is the read only region. Always delta.
(this.EffectiveBootstrap || {}).effective_editor_tag = ($element, options) ->
  quill = new Quill('#' + $element.attr('id'), options)

  content = ($element.attr('data-delta') || '')

  if content.length > 0
    if content.startsWith('{') then quill.setContents($element.data('delta')) else quill.pasteHTML(content)
