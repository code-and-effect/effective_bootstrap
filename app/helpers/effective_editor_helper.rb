module EffectiveEditorHelper

  def effective_editor_tag(delta)
    input_js = { method_name: 'effective_editor_tag', theme: 'snow', readOnly: true, modules: { toolbar: false } }

    content_tag(:div, '', id: "ql-#{delta.object_id}", class: 'effective_editor_content ql-effective', data: { 'input-js-options': input_js, 'delta': delta.presence || '{}'})
  end

end
