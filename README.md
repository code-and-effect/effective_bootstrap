# Effective Bootstrap

Everything you need to get set up with bootstrap 4.

Bootstrap 4 component helpers and form building replacement.

Bootstrap >= 4.0
Rails >= 5.1

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

Make sure you have Bootstrap 4 installed:

Your `application.js` should include

```ruby
//= require jquery3
//= require popper
//= require bootstrap
```

And `application.scss` should include

```sass
@import 'bootstrap';
```

### Install All Form Inputs

This gem packages the javascript/css assets for numerous form inputs.

The assets for these inputs may be included all at once or individually.

To install all available inputs, add the following to your application.js:

```ruby
//= require effective_bootstrap
```

and add the following to your application.css:

```ruby
@import 'effective_bootstrap';
```

All of the included form inputs will now be available with no additional installation tasks.

### Options Passing to JavaScript

All `:input_js => options` passed to any effective_form_input will be used to initialize the Javascript library

For example:

```ruby
= form_for @user do |f|
  = f.effective_date_time_picker :updated_at, :input_js => {:format => 'dddd, MMMM Do YYYY', :showTodayButton => true}
```

or

```ruby
= simple_form_for @user do |f|
  = f.input :updated_at, :as => :effective_date_time_picker, :input_js => {:format => 'dddd, MMMM Do YYYY', :showTodayButton => true}
```

will result in the following call to the Javascript library:

```coffee
$('input.effective_date_time_picker').datetimepicker
  format: 'dddd, MMMM Do YYYY',
  showTodayButton: true
```

Any options passed in this way will be used to initialize the underlying javascript libraries.


```
  = f.submit
  = f.submit 'Save 2'

  = f.submit 'Save', left: true
  = f.submit 'Save', center: true
  = f.submit 'Save', right: true

  = f.submit 'Save', border: false
  = f.submit 'Save', center: true, border: false
  = f.submit 'Save', left: true, border: false

  = f.submit('Save', border: false) do
    = f.save 'Okay'
    = f.save 'Mom'
```

