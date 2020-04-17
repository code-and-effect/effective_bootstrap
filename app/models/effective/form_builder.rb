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

    alias_method :super_number_field, :number_field
    alias_method :super_text_field, :text_field
    alias_method :super_text_area, :text_area

    def clear(name = 'Clear', options = {})
      (options = name; name = 'Clear') if name.kind_of?(Hash)
      Effective::FormInputs::Clear.new(name, options, builder: self).to_html
    end

    def check_box(name, options = {})
      Effective::FormInputs::CheckBox.new(name, options, builder: self).to_html {
        checked_value = options.fetch(:checked_value, '1')
        unchecked_value = options.fetch(:unchecked_value, '0')
        super(name, options.except(:checked_value, :unchecked_value), checked_value, unchecked_value)
      }
    end

    def checks(name, choices = nil, *args)
      options = args.extract_options!.merge!(collection: choices)
      Effective::FormInputs::Checks.new(name, options, builder: self).to_html
    end

    def ck_editor(name, options = {}, &block)
      Effective::FormInputs::CkEditor.new(name, options, builder: self).to_html(&block)
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

    def editor(name, options = {}, &block)
      Effective::FormInputs::Editor.new(name, options, builder: self).to_html(&block)
    end

    def email_field(name, options = {})
      Effective::FormInputs::EmailField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def email_cc_field(name, options = {})
      Effective::FormInputs::EmailCcField.new(name, options, builder: self).to_html
    end

    def error(name = nil, options = {})
      Effective::FormInputs::ErrorField.new(name, options, builder: self).to_html()
    end
    alias_method :errors, :error

    def file_field(name, options = {})
      Effective::FormInputs::FileField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def float_field(name, options = {})
      Effective::FormInputs::FloatField.new(name, options, builder: self).to_html
    end

    def form_group(name = nil, options = {}, &block)
      Effective::FormInputs::FormGroup.new(name, options, builder: self).to_html(&block)
    end

    def integer_field(name, options = {})
      Effective::FormInputs::IntegerField.new(name, options, builder: self).to_html
    end

    # This is gonna be a post?
    def remote_link_to(name, url, options = {}, &block)
      options[:href] ||= url
      Effective::FormInputs::RemoteLinkTo.new(name, options, builder: self).to_html(&block)
    end

    def search_field(name, options = {})
      Effective::FormInputs::SearchField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def number_field(name, options = {})
      Effective::FormInputs::NumberField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def number_text_field(name, options = {})
      Effective::FormInputs::NumberTextField.new(name, options, builder: self).to_html
    end

    def password_field(name, options = {})
      Effective::FormInputs::PasswordField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def percent_field(name, options = {})
      Effective::FormInputs::PercentField.new(name, options, builder: self).to_html
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

    def select_or_text(name, name_text, choices = nil, *args)
      options = args.extract_options!.merge!(name_text: name_text, collection: choices)
      Effective::FormInputs::SelectOrText.new(name, options, builder: self).to_html
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

    def reset(name = 'Reset', options = {})
      (options = name; name = 'Reset') if name.kind_of?(Hash)
      Effective::FormInputs::Reset.new(name, options, builder: self).to_html
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

    def time_zone_select(name, options = {})
      opts = options.merge(collection: Effective::FormInputs::TimeZoneSelect.time_zone_collection)
      Effective::FormInputs::TimeZoneSelect.new(name, opts, builder: self).to_html
    end

    def url_field(name, options = {})
      Effective::FormInputs::UrlField.new(name, options, builder: self).to_html { super(name, options) }
    end

    # Logics
    def hide_if(*args, &block)
      Effective::FormLogics::HideIf.new(*args, builder: self).to_html(&block)
    end

    def show_if(*args, &block)
      Effective::FormLogics::ShowIf.new(*args, builder: self).to_html(&block)
    end

    def show_if_any(*args, &block)
      Effective::FormLogics::ShowIfAny.new(*args, builder: self).to_html(&block)
    end

  end
end

