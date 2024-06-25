# frozen_string_literal: true

module EffectiveIframeHelper

  def iframe_srcdoc_tag(srcdoc)
    content_tag(
      :iframe, 
      '',
      srcdoc: srcdoc,
      style: 'frameborder: 0; border: 0; width: 100%; height: 100%;',
      onload: "this.style.height=(this.contentDocument.body.scrollHeight + 30) + 'px';",
      scrolling: 'no'
    )
  end

end
