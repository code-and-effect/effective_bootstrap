# Effective Bootstrap

Everything your Ruby on Rails 5.1+ application needs to get working with [Twitter Bootstrap 4](https://getbootstrap.com/).

- Bootstrap4 component view helpers.
- SVG icons based on [Inline SVG](https://github.com/jamesmartin/inline_svg), with [Feather Icons](https://feathericons.com) and [FontAwesome](https://fontawesome.com) svg icons to replace the old glyphicons.
- An html-exact form builder that builds on top of Rails' new `form_with` with numerous custom form inputs.

## Getting Started

```ruby
gem 'effective_bootstrap'
```

Run the bundle command to install it:

```console
bundle install
```

Install the configuration file:

```console
rails generate effective_bootstrap:install
```

The generator will install an initializer which describes all configuration options.

Add the following to your `application.js`:

```ruby
//= require jquery3
//= require popper
//= require bootstrap
//= require effective_bootstrap
```

And to your `application.scss`:

```sass
@import 'bootstrap';
@import 'effective_bootstrap';
```

## View Helpers

### Dropdown

https://getbootstrap.com/docs/4.0/components/dropdowns/

```haml
= dropdown do
  = dropdown_link_to 'Something', root_path
  = dropdown_divider
  = dropdown_link_to 'Another', root_path
```

Options include: `dropdown(variation: :dropup|:dropleft|:dropright, split: true|false, right: true|false, btn: 'btn-secondary')`

### ListGroup

https://getbootstrap.com/docs/4.0/components/list-group/

```haml
= list_group do
  = list_group_link_to 'Something', root_path
```

`list_group_link_to` will automatically insert the the `.active` class based on the request path.

### Navbar

https://getbootstrap.com/docs/4.0/components/navbar/

```haml
%nav.navbar.navbar-expand-lg.navbar-light.bg-light
  %a.navbar-brand{href: '/'} Home

  %button.navbar-toggler{type: 'button', data: {toggle: 'collapse', target: '#navContent', 'aria-controls': 'navContent', 'aria-label': 'Toggle navigation'}}
    %span.navbar-toggler-icon

  #navContent.collapse.navbar-collapse
    %ul.navbar-nav.mr-auto
      = nav_link_to 'About', '/about'
      = nav_link_to 'Contact', '/conact'

    %ul.navbar-nav
      - if current_user.present?
        = nav_dropdown('Account', right: true) do
          = nav_link_to 'Settings', user_settings_path

          - if can?(:access, :admin)
            = nav_divider
            = nav_link_to 'Site Admin', '/admin'

          = nav_divider
          = nav_link_to 'Sign Out', destroy_user_session_path, method: :delete
      - else
        = nav_link_to 'Sign In', new_user_session_path
```

`nav_link_to` will automatically insert the `.active` class based on the request path.

## Icon Helpers

Unfortunately, Bootstrap 4 dropped support for glyphicons, so we use a combination of [Inline SVG](https://github.com/jamesmartin/inline_svg), with [Feather Icons](https://feathericons.com) and [FontAwesome](https://fontawesome.com) .svg images (no webfonts) to get back this functionality, even better than it was before.

```haml
= icon('ok') # <svg class='eb-icon eb-icon-ok' ...>
```

```haml
= icon_to('ok', root_path) # <a href='/'><svg class='eb-icon eb-icon-ok' ...></a>
```

A full list of icons can be found here: [All effective_bootstrap icons](https://github.com/code-and-effect/effective_bootstrap/tree/master/app/assets/images/icons)

To overwrite or add an icon, just drop the `.svg` file into your application's `app/assets/images/icons/` directory.

There are also a few helpers for commonly used icons, they all take the form of `x_icon_to(new_thing_path)`:

- `new_icon_to`
- `show_icon_to`
- `edit_icon_to`
- `destroy_icon_to`
- `settings_icon_to`
- `ok_icon_to`
- `approve_icon_to`
- `remove_icon_to`

## Form Builder

Rails 5.1 has introduced a new `form_with` syntax, and soft-deprecated `form_tag` and `form_for`.

This gem includes a [Bootstrap4 Forms](https://getbootstrap.com/docs/4.0/components/forms/) html-exact form builder built on top of `form_with`.

The goal of this form builder is to output beautiful forms while matching the rails form syntax -- you should be able to change an existing `form_with` form to `effective_form_with` with no other changes.

Of course, just the regular form inputs are boring, and this gem extends numerous jQuery/Javascript libraries to level up some inputs.

This is an opinionated Bootstrap4 form builder.

## effective_form_with

Matches the Rails `form_with` tag syntax, with all its `:model`, `:scope`, `:url`, `:method`, etc.

As well, you can specify `layout: :vertical`, `layout: :horizontal`, or `layout: :inline` as per the different Bootstrap form layouts.

```haml
= effective_form_with(model: @user, layout: :horizontal) do |f|
  = f.text_field :name
  = f.submit
```

The default is `layout: :vertical`.

All standard form fields have been implemented as per [Rails 5.1 FormHelper](http://api.rubyonrails.org/v5.1/classes/ActionView/Helpers/FormHelper.html)

### Options

There are three sets of options hashes that you can pass into any form input:

- `wrapper: { class: 'something' }` are applied to the wrapping div tag.
- `input_html: { class: 'something' }` are applied to the input, select or textarea tag itself.
- `input_js: { key: value }` are passed to any custom form input will be used to initialize the Javascript library. For example:

```ruby
= effective_form_with(model: @user) do |f|
  = f.date_field :updated_at, input_js: { useCurrent: 'day', showTodayButton: true }
```

will result in the following call to the Javascript library:

```javascript
$('input').datetimepicker(useCurrent: 'day', showTodayButton: true);
```
Any options passed in this way will be used to initialize the underlying javascript libraries.

## Basic form inputs

The following form inputs are supported, but don't have any kind of custom JavaScript

```haml
= f.check_box
= f.email_field
= f.error_field
= f.number_field
= f.password_field
= f.static_field
= f.text_area
= f.text_field
= f.url_field
```

## Custom date_field, datetime_field, time_field

These custom form inputs are all based on the following awesome project:

Bootstrap 3 Datepicker (https://github.com/Eonasdan/bootstrap-datetimepicker)

```haml
= f.date_field :updated_at
= f.datetime_field :updated_at
= f.time_field :updated_at
```

### Options

The default options used to initialize this form input are as follows:

```ruby
input_js: { showTodayButton: true, showClear: true, useCurrent: 'hour' }
```

For a full list of options, please refer to:

http://eonasdan.github.io/bootstrap-datetimepicker/Options/

### Set Date

Use the following JavaScript to set the date:

```javascript
$('#start_at').data('DateTimePicker').date('2016-05-08')
```

### Disabled Dates

Provide a String, Date, or Range to set the disabled dates.

```ruby
input_js: { disabledDates: '2020-01-01' }
input_js: { disabledDates: Time.zone.now }
input_js: { disabledDates: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month }
input_js: { disabledDates: [Time.zone.now, Time.zone.now + 1.day] }
```

### Linked Dates

By default, when two matching date inputs named `start_*` and `end_*` are present on the same form, they will become linked.

The end date selector will have its date <= start_date disabled.

To disable this behaviour, call with `date_linked: false`.

```ruby
= f.input :end_at, date_linked: false
```

### Events

The date picker library doesn't trigger a regular `change`. Instead you must watch for the `dp.change` event.

More info is available here:

http://eonasdan.github.io/bootstrap-datetimepicker/Events/

## Custom price_field

This custom form input uses no 3rd party jQuery plugins.

It displays a currency formatted value `100.00` but posts the "price as integer" value of `10000` to the server.

Think about this value as "the number of cents".

```haml
= f.price_field :price
```

This gem also includes a rails view helper `price_to_currency` that takes a value like `10000` and displays it as `$100.00`

## Custom select

This custom form input is based on the following awesome project:

Select2 (https://select2.github.io/)

### Usage

As a Rails Form Helper input:

```ruby
= f.select :category, 10.times.map { |x| "Category #{x}"}
= f.select :categories, 10.times.map { |x| "Category #{x}"}, multiple: true
= f.select :categories, 10.times.map { |x| "Category #{x}"}, tags: true
= f.select :categories, {'Active': [['Post A', 1], ['Post B', 2]], 'Past': ['Post C', 3], ['Post D', 4]}, grouped: true
```

### Modes

The standard mode is a replacement for the default single select box.

Passing `multiple: true` will allow multiple selections to be made.

Passing `multiple: true, tags: true` will allow multiple selections to be made, and new value options to be created.  This will allow you to both select existing tags and create new tags in the same form control.

Passing `grouped: true` will enable optgroup support.  When in this mode, the collection should be a Hash of ActiveRecord Relations or Array of Arrays

```ruby
{'Active' => Post.active, 'Past' => Post.past}
{'Active' => [['Post A', 1], ['Post B', 2]], 'Past' => [['Post C', 3], ['Post D', 4]]}
```

Passing `polymorphic: true` will enable polymorphic support.  In this mode, an additional 2 hidden input fields are created alongside the select field.

So calling

```ruby
= f.input :primary_contact, User.all.to_a + Member.all.to_a, polymorphic: true
```

will internally translate the collection into:

```ruby
[['User 1', 'User_1'], ['User 2', 'User_2'], ['Member 100', 'Member_100']]
```

and instead of posting to the server with the parameter `:primary_contact`, it will instead post `{primary_contact_id: 2, primary_contact_type: 'User'}`.

Using both `polymorphic: true` and `grouped: true` is recommended.  In this case the expected collection is as follows:

```ruby
= f.input :primary_contact, {'Users': User.all, 'Members': Member.all}, polymorphic: true, grouped: true
```

### Options

The default options used to initialize this form input are as follows:

```ruby
{
  :theme => 'bootstrap',
  :minimumResultsForSearch => 6,
  :tokenSeparators => [',', ' '],
  :width => 'style',
  :placeholder => 'Please choose',
  :allowClear => !(options[:multiple])  # Only display the Clear 'x' on a single selection box
}
```

### Interesting Available Options

To limit the number of items that can be selected in a multiple select box:

```ruby
maximumSelectionLength: 2
```

To hide the search box entirely:

```ruby
minimumResultsForSearch: 'Infinity'
```

For a full list of options, please refer to: https://select2.github.io/options.html


The following `input_js: options` are not part of the standard select2 API, and are custom `effective_select` functionality only:

To add a css class to the select2 container or dropdown:

```ruby
containerClass: 'custom-container-class'
dropdownClass: 'custom-dropdown-class'
```

to display rich html for the option value:

```ruby
f.select :user, user_tag_collection(User.all), template: :html

def user_tag_collection(users)
  users.map do |user|
    [
      user.to_s,
      user.to_param,
      { 'data-html': content_tag(:span, user.to_s, class: 'user-choice') }
    ]
  end
end
```

### Additional

Call with `single_selected: true` to ensure only the first selected option tag will be `<option selected="selected">`.

This can be useful when displaying multiple options with an identical value.

### Clear value

It's a bit tricky to clear the selected value

```coffeescript
$('select').val('').trigger('change.select2')
```

### Working with dynamic options

The following information applies to `effective_select` only, and is not part of the standard select2 API.

To totally hide (instead of just grey out) any disabled options from the select2 dropdown, initialize the input with:

```ruby
= f.input :category, User.all, hide_disabled: true
```

If you want to dynamically add/remove options from the select field after page load, you must use the `select2:reinitialize` event:

```coffeescript
# When something on my page changes
$(document).on 'change', '.something', (event) ->
  $select = $(event.target).closest('form').find('select.i-want-to-change')  # Find the select2 input to be updated

  # Go through its options, and modify some of them.
  # Using the above 'hide_disabled true' functionality, the following code hides the options from being displayed,
  # but you could actually remove the options, add new ones, or update the values/texts. whatever.
  $select.find('option').each (index, option) ->
    $(option).prop('disabled', true) if index > 10

  # Whenever the underlying options change, you need to manually trigger the following event:
  $select.select2().trigger('select2:reinitialize')
```

### AJAX Support

There is currently no support for using AJAX to load remote data.  This feature is supported by the underlying select2 library and will be implemented here at a future point.

## Custom submit and save

The `f.submit` puts in a wrapper and a default save button, and does the whole icon spin when submit thing.

The `f.save` is purely a input submit button.

```haml
= f.submit
= f.submit 'Save 2'

= f.submit 'Save', left: true
= f.submit 'Save', center: true
= f.submit 'Save', right: true

= f.submit 'Save', border: false
= f.submit 'Save', center: true, border: false
= f.submit 'Save', left: true, border: false

= f.submit(border: false) do
  = f.save 'Save 1'
  = f.save 'Save 2'
```


## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

[Feather icons](https://github.com/feathericons/feather#license) are licensed under the [MIT License](https://opensource.org/licenses/MIT).

[FontAwesome icons](https://fontawesome.com/license) are licensed under the [CC BY 4.0 License](https://creativecommons.org/licenses/by/4.0/) and require this attribution.

## Credits

The authors of this gem are not associated with any of the awesome projects used by this gem.

We are just extending these existing community projects for ease of use with Rails Form Helper and SimpleForm.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
