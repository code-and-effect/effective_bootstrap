module Effective
  class FormBuilder < ActionView::Helpers::FormBuilder

    attr_accessor :layout, :template

    delegate :content_tag, to: :template

    def initialize(object_name, object, template, options)
      @template = template
      @layout = (options.delete(:layout) || :vertical).to_sym
      super
    end

    alias_method :super_text_field, :text_field

    def check_box(name, options = {})
      Effective::FormInputs::CheckBox.new(name, options, builder: self).to_html { super(name, options) }
    end

    def date_field(name, options = {})
      Effective::FormInputs::DateField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def datetime_field(name, options = {})
      Effective::FormInputs::DatetimeField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def email_field(name, options = {})
      Effective::FormInputs::EmailField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def error(name = nil, options = {})
      Effective::FormInputs::ErrorField.new(name, options, builder: self).to_html()
    end
    alias_method :errors, :error

    def form_group(name = nil, options = {}, &block)
      Effective::FormInputs::FormGroup.new(name, options, builder: self).to_html(&block)
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

    def select(name, choices = nil, *args)
      options = args.extract_options!.merge!(collection: choices)
      Effective::FormInputs::Select.new(name, options, builder: self).to_html { super(name, options.delete(:collection), {}, options) }
    end

    def submit(name = 'Submit', options = {})
      Effective::FormInputs::Submit.new(name, options, builder: self).to_html { super(name, options) }
    end

    def static_field(name, options = {}, &block)
      Effective::FormInputs::StaticField.new(name, options, builder: self).to_html(&block)
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

