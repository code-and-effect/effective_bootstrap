# https://imperavi.com/article/

sendMarkPublicRequest = (editor, blob, authenticity_token) ->
  editor.ajax.post(
    url: "/storage/#{blob.signed_id}/mark_public",
    data: {
      id: blob.signed_id,
      authenticity_token: authenticity_token
    }
  )

uploadActiveStorage = (editor, data) ->
  rails_url = '/rails/active_storage/blobs/redirect/'

  # The editor is actually the popup form
  $form = editor.$element.closest('form')

  if $form.length == 0
    $form = editor.$element.closest('.arx-popup')

  permission_public = $form.find("input[name=public_permission]").val() || false

  # This is an effective_form with the article editor in it
  $parentForm = editor.app.$element.closest('form')
  authenticity_token = $parentForm.find("input[name=authenticity_token]").val() || 'missing authenticity token'

  # Attachment classes
  classes = (if permission_public then 'effective-article-editor-attachment effective-article-editor-attachment-permission-public' else 'effective-article-editor-attachment')

  for file in data.files
    upload = new ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads')

    upload.create (error, blob) =>
      sendMarkPublicRequest(editor, blob, authenticity_token) if permission_public

      url = rails_url + blob.signed_id + '/' + blob.filename
      editor.complete({ file: { url: url, name: blob.filename, content_type: blob.content_type }}, data.e)

      # We append this nested attachment html
      attachment = $('<action-text-attachment>')
        .attr('sgid', blob.attachable_sgid)
        .attr('class', classes)

      attachment = $('<div>').append(attachment).html()

      doc = editor.app.editor.getLayout()

      doc
        .find("img[src^='#{rails_url}']:not(.effective-article-editor-attachment)")
        .after(attachment)
        .addClass(classes)

      doc
        .find("img[data-hover-src^='#{rails_url}']:not(.effective-article-editor-hover-attachment)")
        .after(attachment)
        .addClass('effective-article-editor-hover-attachment')

      doc
        .find("a[data-file][data-name='#{file.name}']:not(.action-text-attachment)")
        .after(attachment)
        .addClass(classes)
        .removeAttr('data-file')
        .removeAttr('data-name')

insertUploadByDrop = (response, e) ->
  if @app.block.is()
    instance = @app.block.get()
    target = e.target
    type = instance.getType()

    if ((type == 'card' && target && target.tagName == 'IMG' && instance.hasImage()) || type == 'image')
      return @change(response)
    else if (e && type != 'card' && instance.isEditable())
      @app.insertion.insertPoint(e)

  content_type = (response.file.content_type || '')

  unless content_type.startsWith('image') && @app.filelink
    @app.filelink._insert(response)
  else
    @insert(response)

(this.EffectiveBootstrap || {}).effective_article_editor = ($element, options) ->

  if options['active_storage']
    options['image'] = {
      upload: (editor, data) -> uploadActiveStorage(editor, data)
    }

    options['filelink'] = {
      upload: (editor, data) -> uploadActiveStorage(editor, data)
    }

    options['carousel'] = {
      upload: (editor, data) -> uploadActiveStorage(editor, data)
    }

  editor = ArticleEditor($element, options)
  editor.app.image.insertByDrop = insertUploadByDrop
