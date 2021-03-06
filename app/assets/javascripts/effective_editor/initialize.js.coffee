# https://quilljs.com/docs/download/
# https://github.com/quilljs/quill

Quill.register('modules/imageResize', window.ImageResize.default)
Quill.register('modules/imageDrop', window.QuillImageDropAndPaste)

(this.EffectiveBootstrap || {}).effective_editor = ($element, options) ->
  editor = '#' + $element.attr('id') + '_editor'

  active_storage = options['active_storage']
  delete options['active_storage']

  content_mode = options['content_mode']
  delete options['content_mode']

  if options['modules']['imageDropAndPaste']
    # Image Drop & Paste
    # https://github.com/chenjuneking/quill-image-drop-and-paste
    dropImage = (imageDataUrl, type, imageData) ->
      file = imageData.toFile(type.replace('/', '.'))
      uploadImage(quill, file)

    options['modules']['imageDropAndPaste'] = { handler: dropImage }

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
  if active_storage and content_mode != 'code'
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

  # Insert the image here
  index = try quill.getSelection().index catch err then 0

  # Apply progress indicators
  quill.disable()
  quill.insertText(index, "Uploading image...", 'italic': true)
  EffectiveForm.setCurrentSubmit($form.find('.form-actions'))
  EffectiveForm.submitting($form)

  # Do the direct upload
  fd = new FormData()
  fd.append('blob', file)

  upload = new ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads')

  # After it's been uploaded
  upload.create (error, blob) ->
    # Remove progress indicators
    quill.enable()
    quill.deleteText(index, 18)
    EffectiveForm.reset($form)

    if error
      return alert("Unable to upload: #{error}")

    # Insert the image as an embed with url
    quill.insertEmbed(index, 'image', "/rails/active_storage/blobs/#{blob.signed_id}/#{blob.filename}")

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
