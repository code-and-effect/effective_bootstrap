# https://imperavi.com/article/

uploadActiveStorage = (editor, data) ->
  for file in data.files
    upload = new ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads')

    upload.create (error, blob) =>
      url = '/rails/active_storage/blobs/redirect/' + blob.signed_id + '/' + blob.filename
      editor.complete({ file: { url: url, name: blob.filename, content_type: blob.content_type }}, data.e)

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

  editor = ArticleEditor($element, options)
  editor.app.image.insertByDrop = insertUploadByDrop
