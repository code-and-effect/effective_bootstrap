# frozen_string_literal: true

module EffectiveArticleEditorHelper

  def render_article_editor_action_text_content(content)
    raise('expected content to be an content') unless content.kind_of?(ActionText::Content)

    rendered = render_action_text_content(content)

    if rendered.include?('effective-article-editor')
      doc = Nokogiri::HTML(rendered)
      doc.search('action-text-attachment').each { |fragment| fragment.remove }

      # Filter out <html><body>\n and \n</body></html>
      rendered = doc.inner_html.to_s[13..-16].html_safe
    end

    rendered
  end

end
