module EffectiveFormBuilderHelper
  def effective_form_with(**options, &block)

    options[:class] = [options[:class], 'needs-validation', ('form-inline' if options[:layout] == :inline)].compact.join(' ')

    without_error_proc do
      form_with(**options.merge(builder: Effective::FormBuilder, html: { novalidate: true, onsubmit: 'return EffectiveBootstrap.validate(this);' }), &block)
    end
  end

  private

  # Disables a .fields_with_errors wrapping div when
  def without_error_proc
    original = ActionView::Base.field_error_proc

    begin
      ActionView::Base.field_error_proc = proc { |input, _| input }; yield
    ensure
      ActionView::Base.field_error_proc = original
    end
  end

end
