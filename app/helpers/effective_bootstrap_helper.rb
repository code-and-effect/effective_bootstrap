# Boostrap4 Helpers

module EffectiveBootstrapHelper
  # Button Dropdowns
  # https://getbootstrap.com/docs/4.0/components/dropdowns/
  #
  # = dropdown do
  #   = dropdown_link_to 'Something', root_path
  #   = dropdown_divider
  #   = dropdown_link_to 'Another', root_path
  #
  # Button Dropdowns
  # variations can be :dropup, :dropleft, :dropright
  # split can be true, false
  # right is to right align things
  def dropdown(variation: nil, split: true, btn: 'btn-outline-primary', right: false, &block)
    raise 'expected a block' unless block_given?

    @_dropdown_link_tos = []; yield

    return @_dropdown_link_tos.first if @_dropdown_link_tos.length <= 1

    if split
      first = @_dropdown_link_tos.first
      menu = content_tag(:div, @_dropdown_link_tos[1..-1].join.html_safe, class: ['dropdown-menu', ('dropdown-menu-right' if right)].compact.join(' '))
      split = content_tag(:button, class: "btn #{btn} dropdown-toggle dropdown-toggle-split", type: 'button', 'data-toggle': 'dropdown', 'aria-haspopup': true, 'aria-expanded': false) do
        content_tag(:span, 'Toggle Dropdown', class: 'sr-only')
      end

      content_tag(:div, class: 'btn-group') do
        content_tag(:div, class: ['btn-group', variation.to_s.presence].compact.join(' '), role: 'group') do
          [:dropleft].include?(variation) ? (split + menu + first) : (first + split + menu)
        end
      end
    else
      raise 'split false is unsupported'
    end
  end

  def dropdown_link_to(label, path, options = {})
    if @_dropdown_link_tos.length == 0
      options[:class] = [options[:class], 'btn btn-outline-primary'].compact.join(' ') unless options[:class].to_s.include?('btn-')
      @_dropdown_link_tos << link_to(label, path, options)
    else
      options[:class] = [options[:class], 'dropdown-item'].compact.join(' ')
      @_dropdown_link_tos << link_to(label, path, options)
    end; nil
  end

  def dropdown_divider
    @_dropdown_link_tos << content_tag(:div, '', class: 'dropdown-divider'); nil
  end

  # Nav links and dropdowns
  # Automatically puts in the 'active' class based on request path

  # %ul.navbar-nav
  #   = nav_link_to 'Sign In', new_user_session_path
  #   = nav_dropdown 'Settings' do
  #     = nav_link_to 'Account Settings', user_settings_path
  #     = nav_dropdown_divider
  #     = nav_link_to 'Sign In', new_user_session_path, method: :delete
  def nav_link_to(label, path, opts = {})
    if @_nav_mode == :dropdown  # We insert dropdown-items
      return link_to(label, path, merge_class_key(opts, 'dropdown-item'))
    end

    # Regular nav link item
    content_tag(:li, class: (request.fullpath.include?(path) ? 'nav-item active' : 'nav-item')) do
      link_to(label, path, merge_class_key(opts, 'nav-link'))
    end
  end

  def nav_dropdown(label, right: false, link_class: [], list_class: [], &block)
    raise 'expected a block' unless block_given?

    id = "dropdown-#{''.object_id}"

    content_tag(:li, class: 'nav-item dropdown') do
      content_tag(:a, class: 'nav-link dropdown-toggle', href: '#', id: id, role: 'button', 'data-toggle': 'dropdown', 'aria-haspopup': true, 'aria-expanded': false) do
        label.html_safe
      end + content_tag(:div, class: (right ? 'dropdown-menu dropdown-menu-right' : 'dropdown-menu'), 'aria-labelledby': id) do
        @_nav_mode = :dropdown; yield; @_nav_mode = nil
      end
    end
  end

  def nav_divider
    content_tag(:div, '', class: 'dropdown-divider')
  end

  def merge_class_key(hash, value)
    return { :class => value } unless hash.kind_of?(Hash)

    if hash[:class].present?
      hash.merge!(:class => "#{hash[:class]} #{value}")
    else
      hash.merge!(:class => value)
    end
  end

end
