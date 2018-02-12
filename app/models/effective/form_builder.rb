module Effective
  class FormBuilder < ActionView::Helpers::FormBuilder

    attr_accessor :layout, :template

    delegate :content_tag, to: :template

    def initialize(object_name, object, template, options)
      @template = template
      @layout = (options.delete(:layout) || :vertical).to_sym
      super
    end

    def check_box(name, options = {})
      Effective::FormInputs::CheckBox.new(name, options, builder: self).to_html { super(name, options) }
    end

    def email_field(name, options = {})
      Effective::FormInputs::EmailField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def form_group(name = nil, options = {}, &block)
      Effective::FormInputs::FormGroup.new(name, options, builder: self).to_html(&block)
    end

    def price_field(name, options = {})
      Effective::FormInputs::PriceField.new(name, options, builder: self).to_html {}
    end

    def select(name, choices = nil, options = {}, html_options = {}, &block)
      Effective::FormInputs::Select.new(name, options, html_options: html_options, builder: self).to_html { super(name, choices, options, html_options, &block) }
    end

    def submit(name = 'Submit', options = {})
      Effective::FormInputs::Submit.new(name, options, builder: self).to_html { super(name, options) }
    end

    def text_area(name, options = {})
      Effective::FormInputs::TextArea.new(name, options, builder: self).to_html { super(name, options) }
    end

    def text_field(name, options = {})
      Effective::FormInputs::TextField.new(name, options, builder: self).to_html { super(name, options) }
    end

  end
end

