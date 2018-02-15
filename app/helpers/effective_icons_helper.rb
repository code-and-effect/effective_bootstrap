module EffectiveIconsHelper

  def icon(svg, options = {})
    svg = svg.to_s.chomp('.svg')

    options.reverse_merge!(nocomment: true, preserve_aspect_ratio: true)
    options[:class] = [options[:class], "eb-icon eb-icon-#{svg}"].compact.join(' ')

    inline_svg(svg + '.svg', options)
  end

  def icon_to(svg, url, options = {})
    link_to(icon(svg), url, options)
  end

end

