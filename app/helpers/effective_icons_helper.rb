module EffectiveIconsHelper

  def icon(svg, options = {})
    svg = svg.to_s.chomp('.svg')

    options.reverse_merge!(nocomment: true)
    options[:class] = [options[:class], "eb-icon eb-icon-#{svg}"].compact.join(' ')

    inline_svg(svg + '.svg', options)
  end

  def icon_to(svg, url, options = {})
    link_to(icon(svg), url, options)
  end

  def show_icon_to(path, options = {})
    icon_to('eye-open', path, { title: 'Show' }.merge(options))
  end

  def edit_icon_to(path, options = {})
    icon_to('edit', path, { title: 'Edit' }.merge(options))
  end

  def destroy_icon_to(path, options = {})
    defaults = { title: 'Destroy', data: { method: :delete, confirm: 'Delete this item?' } }
    icon_to('trash', path, defaults.merge(options))
  end

  def settings_icon_to(path, options = {})
    icon_to('cog', path, { title: 'Settings' }.merge(options))
  end

  def ok_icon_to(path, options = {})
    icon_to('ok', path, { title: 'OK' }.merge(options))
  end

  def approve_icon_to(path, options = {})
    icon_to('ok', path, { title: 'Approve' }.merge(options))
  end

  def remove_icon_to(path, options = {})
    icon_to('remove', path, { title: 'Remove' }.merge(options))
  end

end

