# frozen_string_literal: true

module EffectiveArticleEditorHelper
  ACTION_TEXT_ATTACHMENTS = Regexp.new("<action-text-attachment.*?<\/action-text-attachment>")

  def render_article_editor_action_text_content(content)
    raise('expected content to be an ActionText content') unless content.kind_of?(ActionText::Content)

    rendered = content.to_html

    if rendered.include?('effective-article-editor')
      rendered.gsub!(ACTION_TEXT_ATTACHMENTS, '')
    end

    rendered.html_safe
  end

end
