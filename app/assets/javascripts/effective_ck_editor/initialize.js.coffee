# http://eonasdan.github.io/bootstrap-datetimepicker/Options/
(this.EffectiveBootstrap || {}).effective_ck_editor = ($element, options) ->
  setupCkeditor($element)
  initCkeditor($element, $element.data('input-js-options'))

# This is a one-time initialization that is done to check that all the scripts are properly set up
setupCkeditor = ($inputs) ->
  return unless $inputs.length > 0

  input_js_options = $inputs.first().data('input-js-options') || {}

  ckeditor_present = ((try CKEDITOR.version) || '').length > 0
  $head = $('head')

  unless ckeditor_present
    $head.append("<link href='#{input_js_options['effective_ckeditor_css_path']}' type='text/css', media='screen' rel='stylesheet' />")
    jQuery.ajax({url: input_js_options['effective_ckeditor_js_path'], dataType: 'script', cache: true, async: false})

initCkeditor = ($element, input_options) ->
  options =
    toolbar: (input_options['toolbar'] || 'full')
    effectiveRegionType: 'full'
    customConfig: ''
    enterMode: CKEDITOR.ENTER_P
    shiftEnterMode: CKEDITOR.ENTER_BR
    startupOutlineBlocks: true
    startupShowBorders: true
    disableNativeTableHandles: true
    disableNativeSpellChecker: false
    extraPlugins: 'effective_regions,effective_assets'
    removePlugins: 'elementspath'
    format_tags: 'p;h1;h2;h3;h4;h5;h6;pre;div'
    templates: 'effective_regions'
    templates_files: []
    templates_replaceContent: false
    filebrowserWindowHeight: 600
    filebrowserWindowWidth: 800
    filebrowserBrowseUrl: window.CKEDITOR_FILE_BROWSE_URL
    filebrowserImageBrowseUrl: window.CKEDITOR_FILE_BROWSE_URL + '?only=images'
    toolbar_full: [
      { name: 'html', items: ['Sourcedialog', '-', 'ShowBlocks'] },
      { name: 'editing', items: ['Undo', 'Redo'] },
      { name: 'clipboard', items: ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord'] },
      { name: 'justify', items: ['JustifyLeft', 'JustifyCenter', 'JustifyRight']},
      { name: 'basicstyles', items: ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat'] },
      { name: 'lists', items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'] },
      '/'
      { name: 'definedstyles', items: ['Styles', 'Format'] },
      { name: 'links', items: ['Link', 'Unlink', '-', 'Anchor'] },
      { name: 'insert', items: ['Image', 'oembed'] },
      { name: 'lists', items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'] },
      { name: 'insert2', items: ['Table', 'EffectiveReferences', 'Blockquote', 'HorizontalRule', 'PageBreak'] },
      { name: 'colors', items: ['TextColor', 'BGColor'] },
      { name: 'snippets', items: ['Templates', 'InsertSnippet'] }
    ],
    toolbar_simple: [
      { name: 'definedstyles', items: ['Format'] },
      { name: 'html', items: ['ShowBlocks'] },
      { name: 'justify', items: ['JustifyLeft', 'JustifyCenter', 'JustifyRight']}
      { name: 'basicstyles', items: ['Bold', 'Italic', 'Underline'] },
      { name: 'insert', items: ['Link', 'Table'] },
      { name: 'lists', items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'] },
    ]

  options[k] = v for k, v of ($element.data('input-js-options') || {})

  ckeditor = CKEDITOR.replace($element.attr('id'), options)

  ckeditor.on 'insertElement', (event) ->
    element = $(event.data.$)
    if element.is('table')
      element.removeAttr('style').addClass('table')