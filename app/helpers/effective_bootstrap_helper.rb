# Boostrap4 Helpers

module EffectiveBootstrapHelper
  # https://getbootstrap.com/docs/4.0/components/collapse/

  # = collapse('toggle visibility') do
  #   %p Something
  #   %p Collapsed

  # collapse(items.length, class: 'btn btn-primary') do
  #   items.map { |item| content_tag(:div, item.to_s) }.join.html_safe
  # end
  def collapse(label, opts = {}, &block)
    raise 'expected a block' unless block_given?

    id = "collapse-#{''.object_id}"

    link_opts = { 'data-toggle': 'collapse', role: 'button', href: "##{id}", 'aria-controls': "##{id}", 'aria-expanded': false }

    content_tag(:a, label, link_opts.merge(opts)) +
    content_tag(:div, class: 'collapse', id: id) do
      content_tag(:div, capture(&block), class: 'card card-body mt-2')
    end
  end

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
  def dropdown(variation: nil, split: true, btn_class: nil, right: false, &block)
    raise 'expected a block' unless block_given?

    btn_class = btn_class.presence || 'btn-outline-primary'

    @_dropdown_link_tos = []; yield

    return @_dropdown_link_tos.first if @_dropdown_link_tos.length <= 1

    retval = if split
      first = @_dropdown_link_tos.first
      menu = content_tag(:div, @_dropdown_link_tos[1..-1].join.html_safe, class: ['dropdown-menu', ('dropdown-menu-right' if right)].compact.join(' '))
      split = content_tag(:button, class: "btn #{btn_class} dropdown-toggle dropdown-toggle-split", type: 'button', 'data-toggle': 'dropdown', 'aria-haspopup': true, 'aria-expanded': false) do
        content_tag(:span, 'Toggle Dropdown', class: 'sr-only')
      end

      content_tag(:div, class: 'btn-group') do
        content_tag(:div, class: ['btn-group', variation.to_s.presence].compact.join(' '), role: 'group') do
          [:dropleft].include?(variation) ? (split + menu) : (first + split + menu)
        end + ([:dropleft].include?(variation) ? first : '').html_safe
      end
    else
      raise 'split false is unsupported'
    end

    @_dropdown_link_tos = nil

    retval
  end

  # This is a special variant of dropdown
  # dots do
  #   = dropdown_link_to 'Edit', edit_path(thing)
  def dots(options = nil, &block)
    (options ||= {})[:class] = "dropdown dropdown-dots #{options.delete(:class)}".strip

    content_tag(:span, options) do
      content_tag(:button, class: "btn btn-dots dropdown-toggle #{options.delete(:button_class)}", 'aria-expanded': true, 'aria-haspopup': true, 'data-toggle': 'dropdown', type: 'button') do
      end + content_tag(:div, capture(&block), class: 'dropdown-menu')
    end
  end

  def dots_link_to(label, path, options = {})
    options[:class] = [options[:class], 'dropdown-item'].compact.join(' ')

    concat link_to(label, path, options)
  end

  # Works with dots do and dropdown do
  def dropdown_link_to(label, path, options = {})
    btn_class = options.delete(:btn_class).presence || 'btn-outline-primary'

    unless @_dropdown_link_tos
      options[:class] = [options[:class], 'dropdown-item'].compact.join(' ')
      return link_to(label, path, options)
    end

    if @_dropdown_link_tos.length == 0
      options[:class] = [options[:class], 'btn', btn_class].compact.join(' ')
    else
      options[:class] = [options[:class], 'dropdown-item'].compact.join(' ')
    end

    @_dropdown_link_tos << link_to(label, path, options)

    nil
  end

  # Works with dots ao and dropdown do
  def dropdown_divider
    unless @_dropdown_link_tos
      content_tag(:div, '', class: 'dropdown-divider')
    else
      @_dropdown_link_tos << content_tag(:div, '', class: 'dropdown-divider')
      nil
    end
  end

  def list_group(&block)
    content_tag(:div, yield, class: 'list-group')
  end

  # List group
  # = list_group_link_to
  # Automatically puts in the 'active' class based on request path
  def list_group_link_to(label, path, opts = {})
    # Regular link item
    opts[:class] = if request.fullpath.include?(path)
      [opts[:class], 'list-group-item active'].compact.join(' ')
    else
      [opts[:class], 'list-group-item'].compact.join(' ')
    end

    link_to(label.to_s, path, opts)
  end

  # Nav links and dropdowns
  # Automatically puts in the 'active' class based on request path

  # %ul.navbar-nav
  #   = nav_link_to 'Sign In', new_user_session_path
  #   = nav_dropdown 'Settings' do
  #     = nav_link_to 'Account Settings', user_settings_path
  #     = nav_divider
  #     = nav_link_to 'Sign In', new_user_session_path, method: :delete
  def nav_link_to(label, path, opts = {})
    if @_nav_mode == :dropdown  # We insert dropdown-items
      return link_to(label, path, merge_class_key(opts, 'dropdown-item'))
    end

    strict = opts.delete(:strict)
    active = (strict ? (request.fullpath == path) : request.fullpath.include?(path))

    # Regular nav link item
    content_tag(:li, class: (active ? 'nav-item active' : 'nav-item')) do
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

  # Tabs DSL
  # Inserts both the tablist and the tabpanel

  # = tabs do
  #   = tab 'Imports' do
  #     %p Imports

  #   = tab 'Exports' do
  #     %p Exports

  # If you pass active 'label' it will make that tab active. Otherwise first.
  # Unique will make sure the tab html IDs are unique
  # $('#tab-demographics').tab('show')
  def tabs(active: nil, unique: false, list: {}, content: {}, &block)
    raise 'expected a block' unless block_given?

    @_tab_mode = :tablist
    @_tab_active = (active || :first)
    @_tab_unique = ''.object_id if unique

    content_tag(:ul, {class: 'nav nav-tabs', role: 'tablist'}.merge(list)) do
      yield # Yield to tab the first time
    end +
    content_tag(:div, {class: 'tab-content'}.merge(content)) do
      @_tab_mode = :content
      @_tab_active = (active || :first)
      yield # Yield to tab the second time
    end
  end

  def tab(label, options = {}, &block)
    controls = options.delete(:controls) || label.to_s.parameterize.gsub('_', '-')
    controls = controls[1..-1] if controls[0] == '#'
    controls = "#{controls}-#{@_tab_unique}" if @_tab_unique

    active = (@_tab_active == :first || @_tab_active == label)

    @_tab_active = nil if @_tab_active == :first

    if @_tab_mode == :tablist # Inserting the label into the tablist top
      content_tag(:li, class: 'nav-item') do
        content_tag(:a, label, id: ('tab-' + controls), class: ['nav-link', ('active' if active)].compact.join(' '), href: '#' + controls, 'aria-controls': controls, 'aria-selected': active.to_s, 'data-toggle': 'tab', role: 'tab')
      end
    else # Inserting the content into the tab itself
      classes = ['tab-pane', 'fade', ('show active' if active), options[:class].presence].compact.join(' ')
      content_tag(:div, id: controls, class: classes, role: 'tabpanel', 'aria-labelledby': ('tab-' + controls)) do
        yield
      end
    end
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
