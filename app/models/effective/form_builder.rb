module Effective
  class FormBuilder < ActionView::Helpers::FormBuilder

    attr_accessor :template, :layout, :action, :readonly, :disabled, :remote

    delegate :content_tag, to: :template

    def initialize(object_name, object, template, options)
      @template = template

      @layout = (options.delete(:layout) || :vertical).to_sym
      @action = options.delete(:action)
      @readonly = options.delete(:readonly)
      @disabled = options.delete(:disabled)
      @remote = options[:remote]

      super
    end

    alias_method :super_text_field, :text_field

    def check_box(name, options = {})
      Effective::FormInputs::CheckBox.new(name, options, builder: self).to_html { super(name, options) }
    end

    def checks(name, choices = nil, *args)
      options = args.extract_options!.merge!(collection: choices)
      Effective::FormInputs::Checks.new(name, options, builder: self).to_html
    end

    def date_field(name, options = {})
      Effective::FormInputs::DateField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def datetime_field(name, options = {})
      Effective::FormInputs::DatetimeField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def delete(name = 'Remove', url = nil, options = {}, &block)
      options[:href] ||= url
      Effective::FormInputs::Delete.new(name, options, builder: self).to_html(&block)
    end

    def email_field(name, options = {})
      Effective::FormInputs::EmailField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def error(name = nil, options = {})
      Effective::FormInputs::ErrorField.new(name, options, builder: self).to_html()
    end
    alias_method :errors, :error

    def file_field(name, options = {})
      Effective::FormInputs::FileField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def form_group(name = nil, options = {}, &block)
      Effective::FormInputs::FormGroup.new(name, options, builder: self).to_html(&block)
    end

    # This is gonna be a post?
    def post_to(name, url, options = {}, &block)
      options[:href] ||= url
      Effective::FormInputs::PostTo.new(name, options, builder: self).to_html(&block)
    end

    def number_field(name, options = {})
      Effective::FormInputs::NumberField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def password_field(name, options = {})
      Effective::FormInputs::PasswordField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def phone_field(name, options = {})
      Effective::FormInputs::PhoneField.new(name, options, builder: self).to_html { super(name, options) }
    end
    alias_method :tel_field, :phone_field
    alias_method :telephone_field, :phone_field

    def price_field(name, options = {})
      Effective::FormInputs::PriceField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def save(name = 'Save', options = {})
      (options = name; name = 'Save') if name.kind_of?(Hash)
      Effective::FormInputs::Save.new(name, options, builder: self).to_html { super(name, options) }
    end

    def select(name, choices = nil, *args)
      options = args.extract_options!.merge!(collection: choices)
      Effective::FormInputs::Select.new(name, options, builder: self).to_html
    end

    def submit(name = 'Save', options = {}, &block)
      (options = name; name = 'Save') if name.kind_of?(Hash)
      Effective::FormInputs::Submit.new(name, options, builder: self).to_html(&block)
    end

    def static_field(name, options = {}, &block)
      options = { value: options } if options.kind_of?(String)
      Effective::FormInputs::StaticField.new(name, options, builder: self).to_html(&block)
    end

    def radios(name, choices = nil, *args)
      options = args.extract_options!.merge!(collection: choices)
      Effective::FormInputs::Radios.new(name, options, builder: self).to_html
    end

    def text_area(name, options = {})
      Effective::FormInputs::TextArea.new(name, options, builder: self).to_html { super(name, options) }
    end

    def text_field(name, options = {})
      Effective::FormInputs::TextField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def time_field(name, options = {})
      Effective::FormInputs::TimeField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def url_field(name, options = {})
      Effective::FormInputs::UrlField.new(name, options, builder: self).to_html { super(name, options) }
    end

  end
end

