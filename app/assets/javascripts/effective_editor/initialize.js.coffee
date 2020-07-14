# https://quilljs.com/docs/download/
# https://github.com/quilljs/quill

Quill.register('modules/imageResize', window.ImageResize.default)

(this.EffectiveBootstrap || {}).effective_editor = ($element, options) ->
  editor = '#' + $element.attr('id') + '_editor'

  active_storage = options['active_storage']
  delete options['active_storage']

  content_mode = options['content_mode']
  delete options['content_mode']

  quill = new Quill($element.siblings(editor).get(0), options)
  content = $element.val() || ''

  if content.length > 0
    if content.startsWith('{')
      quill.setContents(JSON.parse(content))
    else if content_mode == 'code'
      quill.setText(content)
    else if content.startsWith('<')
      quill.pasteHTML(content)
    else
      quill.setText(content)

  if content_mode == 'code'
    quill.formatText(0, quill.getLength(), 'code-block', true)

    quill.on 'text-change', ->
      $element.val(quill.getText())
      $element.trigger('change')
  else if content_mode == 'html'
    quill.on 'text-change', ->
      html = $(editor).children('.ql-editor').html()
      html = '' if html == '<p><br></p>' || html == '<p></p>'
      $element.val(html)
      $element.trigger('change')
  else
    quill.on 'text-change', (delta, oldDelta, source) ->
      # If this is insert link...
      if delta['ops'] && delta['ops'].some( (element) -> element['attributes'] && element['attributes']['link'] )
        length = quill.getLength()
        range = quill.getSelection(true)

        if (range.index + range.length + 1 == length)
          quill.insertText(length - 1, " ", 'link', false);
          quill.setSelection(range.index + range.length + 2);
        else
         quill.setSelection(range.index + range.length + 1);

      $element.val(JSON.stringify(quill.getContents()))
      $element.trigger('change')

  $element.on 'quill:focus', (event) -> quill.focus()

  # Active Storage support
  if active_storage
    quill.getModule('toolbar').addHandler('image', -> createImage(quill))

# Active Support Direct Upload
createImage = (quill) ->
  input = document.createElement('input')
  input.setAttribute('type', 'file')
  input.click()

  input.onchange = ->
    file = input.files[0]

    if(/^image\//.test(file.type) == false)
      return alert('Please upload an image')

    if file.size > 20000000
      return alert('Please upload an image less than 20mb')

    uploadImage(quill, file)

uploadImage = (quill, file) ->
  $form = $(quill.container).closest('form')

  EffectiveForm.setCurrentSubmit($form.find('.form-actions').first())
  EffectiveForm.submitting($form)

  fd = new FormData()
  fd.append('blob', file)

  upload = new ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads')

  upload.create (error, blob) ->
    if error
      alert("Unable to upload: #{error}")
    else
      insertImage(quill, "/rails/active_storage/blobs/#{blob.signed_id}/#{blob.filename}")

    EffectiveForm.reset($form)

insertImage = (quill, url) ->
  quill.insertEmbed(quill.getSelection().index, 'image', url)

# This is the read only region. Always delta.
(this.EffectiveBootstrap || {}).effective_editor_tag = ($element, options) ->
  quill = new Quill('#' + $element.attr('id'), options)

  content = ($element.attr('data-content') || '')
  content_mode = $element.data('input-js-options')['content_mode']

  if content.length > 0
    if content.startsWith('{')
      quill.setContents(JSON.parse(content))
    else if content_mode == 'code'
      quill.setText(content)
    else if content.startsWith('<')
      quill.pasteHTML(content)
    else
      quill.setText(content)

  if content_mode == 'code'
    quill.formatText(0, quill.getLength(), 'code-block', true)
