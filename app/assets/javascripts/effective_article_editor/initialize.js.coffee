# https://imperavi.com/article/

uploadActiveStorage = (editor, data) ->
  for file in data.files
    upload = new ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads')

    upload.create (error, blob) =>
      url = '/rails/active_storage/blobs/redirect/' + blob.signed_id + '/' + blob.filename
      editor.complete({ file: { url: url, name: blob.filename }}, data.e)

(this.EffectiveBootstrap || {}).effective_article_editor = ($element, options) ->

  if options['active_storage']
    options['image'] = {
      upload: (editor, data) -> uploadActiveStorage(editor, data)
    }

    options['filelink'] = {
      upload: (editor, data) -> uploadActiveStorage(editor, data)
    }

  ArticleEditor($element, options)
