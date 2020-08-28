# Boostrap4 Helpers

module EffectiveBootstrapHelper
  # This is a special variant of collapse
  # = accordion do
  #   = collapse('Add thing...') do
  #     %p Something to add
  def accordion(options = nil, &block)
    (options ||= {})[:class] = "accordion #{options.delete(:class)}".strip

    id = "accordion-#{''.object_id}"

    @_accordion_active = id
    content = content_tag(:div, capture(&block), options.merge(id: id))
    @_accordion_active = nil
    content
  end

  # https://getbootstrap.com/docs/4.0/components/collapse/

  # = collapse('toggle visibility') do
  #   %p Something Collapsed

  # = collapse('already expanded', show: true) do
  #   %p Something Expanded

  # collapse(items.length, class: 'btn btn-primary', class: 'mt-2') do
  #   items.map { |item| content_tag(:div, item.to_s) }.join.html_safe
  # end
  def collapse(label, opts = {}, &block)
    raise 'expected a block' unless block_given?

    id = "collapse-#{''.object_id}"
    show = (opts.delete(:show) == true)

    link_opts = { 'data-toggle': 'collapse', role: 'button', href: "##{id}", 'aria-controls': "##{id}", 'aria-expanded': show }

    link_opts[:class] = opts.delete(:link_class) || 'btn btn-link'
    div_class = opts.delete(:div_class)
    card_class = opts.delete(:card_class) || 'card card-body my-2'

    if @_accordion_active
      # Accordion collapse
      content_tag(:div, class: "card mb-0") do
        content_tag(:div, class: "card-header") do
          content_tag(:h2, class: "mb-0") do
            content_tag(:button, label, link_opts.merge(class: "btn btn-link"))
          end
        end +
        content_tag(:div, id: id, class: ['collapse', div_class, ('show' if show)].compact.join(' '), "data-parent": "##{@_accordion_active}") do
          content_tag(:div, capture(&block), class: "card-body")
        end
      end
    else
      # Normal collapse
      content_tag(:a, label, link_opts) +
      content_tag(:div, id: id, class: ['collapse', div_class, ('show' if show)].compact.join(' ')) do
        content_tag(:div, capture(&block), class: card_class)
      end
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
  def dropdown(variation: nil, split: true, btn_class: nil, btn_content: nil, right: false, &block)
    raise 'expected a block' unless block_given?

    btn_class = btn_class.presence || 'btn-outline-primary'

    @_dropdown_link_tos = []
    @_dropdown_split = split

    # process dropdown_link_tos
    yield

    return @_dropdown_link_tos.first if @_dropdown_link_tos.length <= 1

    # Build tags
    first = @_dropdown_link_tos.first

    button = content_tag(:button, class: "btn #{btn_class} dropdown-toggle" + (split ? " dropdown-toggle-split" : ''), type: 'button', 'data-toggle': 'dropdown', 'aria-haspopup': true, 'aria-expanded': false) do
      btn_content || content_tag(:span, 'Toggle Dropdown', class: 'sr-only')
    end

    menu = if split
      content_tag(:div, @_dropdown_link_tos[1..-1].join.html_safe, class: ['dropdown-menu', ('dropdown-menu-right' if right)].compact.join(' '))
    else
      content_tag(:div, @_dropdown_link_tos.join.html_safe, class: ['dropdown-menu', ('dropdown-menu-right' if right)].compact.join(' '))
    end

    retval = if split
      content_tag(:div, class: 'btn-group') do
        content_tag(:div, class: ['btn-group', variation.to_s.presence].compact.join(' '), role: 'group') do
          [:dropleft].include?(variation) ? (button + menu) : (first + button + menu)
        end + ([:dropleft].include?(variation) ? first : '').html_safe
      end
    else
      content_tag(:div, class: 'dropdown') do
        button + menu
      end
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

    if @_dropdown_link_tos.length == 0 && @_dropdown_split
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

  # Pagination
  #
  # https://getbootstrap.com/docs/4.0/components/pagination/
  # Builds a pagination based on the given collection, current url and params[:page]
  #
  # = paginate(@posts, per_page: 10)
  #
  # Add this to your model
  # scope :paginate, -> (page: nil, per_page: 10) {
  #   page = (page || 1).to_i
  #   offset = [(page - 1), 0].max * per_page

  #   limit(per_page).offset(offset)
  # }
  #
  # Add this to your controller:
  # @posts = Post.all.paginate(page: params[:page])
  #
  # Add this to your view
  # %nav= paginate(@posts, per_page: 10)
  #
  def bootstrap_paginate(collection, per_page:, url: nil, window: 2, collection_count: nil, render_single_page: false)
    raise 'expected an ActiveRecord::Relation' unless collection.respond_to?(:limit) && collection.respond_to?(:offset)

    collection_count ||= collection.limit(nil).offset(nil).count # You can pass the total count, or not.

    page = (params[:page] || 1).to_i
    last = (collection_count.to_f / per_page).ceil

    return unless (last > 1 || render_single_page) # If there's only 1 page, don't render a pagination at all.

    # Build URL
    uri = URI(url || request.fullpath)
    params = Rack::Utils.parse_nested_query(uri.query)
    url = uri.path + '?'

    # Pagination Tags
    prev_tag = content_tag(:li, class: ['page-item', ('disabled' if page <= 1)].compact.join(' ')) do
      link_to(content_tag(:span, 'Previous'.html_safe), (page <= 1 ? '#' : url + params.merge('page' => page - 1).to_query),
        class: 'page-link', 'aria-label': 'Previous', title: 'Previous', 'aria-disabled': ('true' if page <= 1), 'tabindex': ('-1' if page <= 1)
      )
    end

    next_tag = content_tag(:li, class: ['page-item', ('disabled' if page >= last)].compact.join(' ')) do
      link_to(content_tag(:span, 'Next'.html_safe), (page >= last ? '#' : url + params.merge('page' => page + 1).to_query),
        class: 'page-link', 'aria-label': 'Next', title: 'Next', 'aria-disabled': ('true' if page >= last), 'tabindex': ('-1' if page >= last)
      )
    end

    dots_tag = content_tag(:li, class: 'page-item disabled') do
      link_to('...', '#', class: 'page-link', 'aria-label': '...', 'aria-disabled': true, tabindex: '-1')
    end

    # Calculate Windows
    length = 1 + (window * 2)
    left = 1.upto(last).to_a.first(length)
    right = 1.upto(last).to_a.last(length)
    center = []
    max = length + 2

    if last <= max
      left = left - right
      right = right - left
    elsif left.include?(page + 1)
      right = [last]
      left = left - right
    elsif right.include?(page - 1)
      left = [1]
      right = right - left
    else
      left = [1]
      right = [last]
      center = (page - window + 1).upto(page + window - 1).to_a
    end

    # Render the pagination
    content_tag(:ul, class: 'pagination') do
      [
        prev_tag,
        left.map { |index| bootstrap_paginate_tag(index, page, url, params) },
        (dots_tag if last > max && left == [1]),
        center.map { |index| bootstrap_paginate_tag(index, page, url, params) },
        (dots_tag if last > max && right == [last]),
        right.map { |index| bootstrap_paginate_tag(index, page, url, params) },
        next_tag
      ].flatten.join.html_safe
    end
  end

  def bootstrap_paginate_tag(index, page, url, params)
    content_tag(:li, class: ['page-item', ('active' if index == page)].compact.join(' '), title: "Page #{index}") do
      link_to(index, (url + params.merge('page' => index).to_query), class: 'page-link')
    end
  end

  # Let Kaminari override this method.
  alias_method(:paginate, :bootstrap_paginate) unless (respond_to?(:paginate) || defined?(Kaminari))

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
