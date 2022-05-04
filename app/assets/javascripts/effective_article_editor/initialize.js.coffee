# https://imperavi.com/article/

uploadActiveStorage = (editor, data) ->
  rails_url = '/rails/active_storage/blobs/redirect/'

  for file in data.files
    upload = new ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads')

    upload.create (error, blob) =>
      url = rails_url + blob.signed_id + '/' + blob.filename
      editor.complete({ file: { url: url, name: blob.filename, content_type: blob.content_type }}, data.e)

      # We append this nested attachment html
      attachment = $('<action-text-attachment>')
        .attr('sgid', blob.attachable_sgid)
        .attr('class', 'effective-article-editor-attachment')

      attachment = $('<div>').append(attachment).html()

      doc = editor.app.editor.getLayout()

      doc
        .find("img[src^='#{rails_url}']:not(.effective-article-editor-attachment)")
        .after(attachment)
        .addClass('effective-article-editor-attachment')

      doc
        .find("a[data-file][data-name='#{file.name}']:not(.action-text-attachment)")
        .after(attachment)
        .addClass('effective-article-editor-attachment')
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

  editor = ArticleEditor($element, options)
  editor.app.image.insertByDrop = insertUploadByDrop
