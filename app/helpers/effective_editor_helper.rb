# frozen_string_literal: true

module EffectiveEditorHelper

  def effective_editor_tag(content, options = {})
    content = content.presence || '{}'

    content_mode = (
      if options.delete(:delta)
        :delta
      elsif options.delete(:html)
        :html
      elsif options.delete(:code)
        :code
      else
        :delta
      end
    )

    input_js = {
      method_name: 'effective_editor_tag',
      theme: 'snow',
      readOnly: true,
      content_mode: content_mode,
      modules: { toolbar: false, syntax: (content_mode == :code) }
    }

    content_tag(:div, '', id: "ql-#{content.object_id}", class: 'effective_editor_content ql-effective', data: { 'input-js-options': input_js, 'content': content })
  end

end
