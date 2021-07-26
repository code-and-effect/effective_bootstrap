# frozen_string_literal: true

# Boostrap4 Helpers

module EffectiveBootstrapHelper
  # This is a special variant of collapse
  # = accordion do
  #   = collapse('Add thing...') do
  #     %p Something to add
  def accordion(options = nil, &block)
    (options ||= {})[:class] = "accordion #{options.delete(:class)}".strip

    id = "accordion-#{effective_bootstrap_unique_id}"

    @_accordion_active = id
    content = content_tag(:div, capture(&block), options.merge(id: id))
    @_accordion_active = nil
    content
  end

  # https://getbootstrap.com/docs/4.0/components/card/
  # = card('title do')
  #   %p Stuff
  # = card('Stuff', header: 'header title')
  def card(value = nil, opts = {}, &block)
    raise('expected a block') unless block_given?

    if value.kind_of?(Hash)
      opts = value; value = nil
    end

    header = opts.delete(:header)
    title = opts.delete(:title) || value

    content_tag(:div, merge_class_key(opts, 'card mb-4')) do
      header = content_tag(:div, header, class: 'card-header') if header.present?

      body = content_tag(:div, class: 'card-body') do
        if title.present?
          content_tag(:h5, title, class: 'card-title') + capture(&block)
        else
          capture(&block)
        end
      end

      header ? (header + body) : body
    end
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

    id = "collapse-#{effective_bootstrap_unique_id}"
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
  DROPDOWN_SPLIT_OPTS = {class: "btn dropdown-toggle dropdown-toggle-split btn-sm btn-outline-primary", type: 'button', 'data-toggle': 'dropdown', 'aria-haspopup': true, 'aria-expanded': false}
  DROPDOWN_UNSPLIT_OPTS= {class: "btn dropdown-toggle btn-sm btn-outline-primary", type: 'button', 'data-toggle': 'dropdown', 'aria-haspopup': true, 'aria-expanded': false}

  DROPDOWN_DROPLEFT_GROUP_OPTS = {class: 'btn-group'}
  DROPDOWN_DROPLEFT_OPTS = {class: 'btn-group dropleft', role: 'group'}

  DROPDOWN_MENU_OPTS = {class: 'dropdown-menu'}
  DROPDOWN_MENU_RIGHT_OPTS = {class: 'dropdown-menu dropdown-menu-right'}

  DROPDOWN_BTN_CLASS = 'btn-sm btn-outline-primary'
  DROPDOWN_TOGGLE_DROPDOWN = "<span class='sr-only'>Toggle Dropdown</span>".html_safe

  def dropdown(variation: nil, split: true, btn_class: nil, btn_content: nil, right: false, &block)
    raise 'expected a block' unless block_given?

    btn_class ||= DROPDOWN_BTN_CLASS

    # Process all dropdown_link_tos
    @_dropdown_link_tos = []
    @_dropdown_split = split
    @_dropdown_button_class = btn_class
    yield

    return @_dropdown_link_tos.first if @_dropdown_link_tos.length <= 1

    # Build tags
    first = @_dropdown_link_tos.first

    button_opts = (split ? DROPDOWN_SPLIT_OPTS : DROPDOWN_UNSPLIT_OPTS)

    if btn_class != DROPDOWN_BTN_CLASS
      button_opts[:class] = button_opts[:class].sub(DROPDOWN_BTN_CLASS, btn_class)
    end

    button = content_tag(:button, button_opts) do
      btn_content || DROPDOWN_TOGGLE_DROPDOWN
    end

    menu_opts = (right ? DROPDOWN_MENU_RIGHT_OPTS : DROPDOWN_MENU_OPTS)

    menu = if split
      content_tag(:div, @_dropdown_link_tos[1..-1].join.html_safe, menu_opts)
    else
      content_tag(:div, @_dropdown_link_tos.join.html_safe, menu_opts)
    end

    @_dropdown_link_tos = nil

    if split && variation == :dropleft
      content_tag(:div, DROPDOWN_DROPLEFT_GROUP_OPTS) do
        content_tag(:div, (button + menu), DROPDOWN_DROPLEFT_OPTS) + first.html_safe
      end
    elsif split
      content_tag(:div, class: 'btn-group') do
        content_tag(:div, (first + button + menu), class: "btn-group #{variation}", role: 'group')
      end
    else
      content_tag(:div, (button + menu), class: 'dropdown')
    end
  end

  # This is a special variant of dropdown
  # dots do
  #   = dropdown_link_to 'Edit', edit_path(thing)
  def dots(options = nil, &block)
    (options ||= {})[:class] = "dropdown dropdown-dots #{options.delete(:class)}".strip

    content_tag(:div, options) do
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
    btn_class = options.delete(:btn_class).presence || @_dropdown_button_class || 'btn-outline-primary'

    unless @_dropdown_link_tos
      options[:class] = (options[:class] ? "dropdown-item #{options[:class]}" : 'dropdown-item')
      return link_to(label, path, options)
    end

    if @_dropdown_link_tos.length == 0 && @_dropdown_split
      options[:class] = (options[:class] ? "btn #{btn_class} #{options[:class]}" : "btn #{btn_class}")
    else
      options[:class] = (options[:class] ? "dropdown-item #{options[:class]}" : 'dropdown-item')
    end

    @_dropdown_link_tos << link_to(label, path, options)

    nil
  end

  # Works with dots ao and dropdown do
  def dropdown_divider(options = {})
    options[:class] = [options[:class], 'dropdown-divider'].compact.join(' ')

    unless @_dropdown_link_tos
      content_tag(:div, '', options)
    else
      @_dropdown_link_tos << content_tag(:div, '', options)
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

    id = "dropdown-#{effective_bootstrap_unique_id}"

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

  # Breadcrumb
  #
  # https://getbootstrap.com/docs/4.0/components/breadcrumb/
  # Builds a breadcrumb based on the controller namespace, action and @page_title instance variable
  #
  def bootstrap_breadcrumb(root_title: nil, root_path: nil, index_title: nil, index_path: nil, page_title: nil)
    effective_resource = (@_effective_resource || Effective::Resource.new(controller_path))
    resource = instance_variable_get('@' + effective_resource.name) if effective_resource.name

    root_title ||= 'Home'
    root_path ||= '/'

    index_title ||= controller.class.name.split('::').last.sub('Controller', '').titleize
    index_path ||= effective_resource.action_path(:index) || request.path.split('/')[0...-1].join('/')

    page_title ||= (@page_title || resource&.to_s || controller.action_name.titleize)

    # Build items
    # An array of arrays [[title, url]]
    items = []

    # Namespaces
    Array(effective_resource.namespace).each do |namespace|
      items << [namespace.titleize, '/' + namespace]
    end

    # Home
    items << [root_title, '/'] unless items.present?

    # Controller index action
    items << [index_title, index_path] unless controller.action_name == 'index'

    # Always
    items << [page_title, nil]

    # Now take items and turn them into breadcrumbs
    content_tag(:ol, class: 'breadcrumb') do
      (items[0...-1].map do |title, path|
        content_tag(:li, link_to(title, path, title: title), class: 'breadcrumb-item')
      end + items[-1..-1].map do |title, path|
        content_tag(:li, title, class: 'breadcrumb-item active', 'aria-current': 'page')
      end).join.html_safe
    end
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
    @_tab_unique = effective_bootstrap_unique_id if unique

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

    if @_tab_mode == :tablist_vertical
      content_tag(:a, label, id: ('tab-' + controls), class: ['nav-link', ('active' if active)].compact.join(' '), href: '#' + controls, 'aria-controls': controls, 'aria-selected': active.to_s, 'data-toggle': 'tab', role: 'tab')
    elsif @_tab_mode == :tablist # Inserting the label into the tablist top
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

  def vertical_tabs(active: nil, unique: false, list: {}, content: {}, &block)
    raise 'expected a block' unless block_given?

    @_tab_mode = :tablist_vertical
    @_tab_active = (active || :first)
    @_tab_unique = effective_bootstrap_unique_id if unique

    content_tag(:div, class: 'row border') do
      content_tag(:div, class: 'col-3 border-right') do
        content_tag(:div, {class: 'nav flex-column nav-pills my-2', role: 'tablist', 'aria-orientation': :vertical}.merge(list)) do
          yield # Yield to tab the first time
        end
      end +
      content_tag(:div, class: 'col-9') do
        content_tag(:div, {class: 'tab-content my-2'}.merge(content)) do
          @_tab_mode = :content
          @_tab_active = (active || :first)
          yield # Yield to tab the second time
        end
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

  def effective_bootstrap_unique_id
    # Set the first unique value
    @_effective_bootstrap_unique_id ||= Time.zone.now.to_i

    # Everytime we access this function make a new one
    @_effective_bootstrap_unique_id = @_effective_bootstrap_unique_id + 1

    # Return the updated value
    @_effective_bootstrap_unique_id
  end

end
