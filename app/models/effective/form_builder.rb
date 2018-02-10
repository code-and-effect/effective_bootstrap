module Effective
  class FormBuilder < ActionView::Helpers::FormBuilder

    attr_accessor :layout, :template

    delegate :content_tag, to: :template

    def initialize(object_name, object, template, options)
      @template = template
      @layout = options.delete(:layout)
      super
    end

    def check_box(name, options = {})
      Effective::FormInputs::CheckBox.new(name, options, builder: self).to_html { super(name, options) }
    end

    def email_field(name, options = {})
      Effective::FormInputs::EmailField.new(name, options, builder: self).to_html { super(name, options) }
    end

    def text_field(name, options = {})
      Effective::FormInputs::TextField.new(name, options, builder: self).to_html { super(name, options) }
    end

  end
end

