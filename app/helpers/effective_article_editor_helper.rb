# frozen_string_literal: true

module EffectiveArticleEditorHelper

  def render_article_editor_action_text_content(content)
    raise('expected content to be an ActionText content') unless content.kind_of?(ActionText::Content)

    rendered = content.to_html

    if rendered.include?('effective-article-editor')
      doc = Nokogiri::HTML(rendered)
      doc.search('action-text-attachment').each { |fragment| fragment.remove }

      # Filter out <html><body>\n and \n</body></html>
      rendered = doc.inner_html.to_s[13..-16]
    end

    rendered.html_safe
  end

end
